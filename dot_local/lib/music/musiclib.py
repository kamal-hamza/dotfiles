"""musiclib - shared engine for music-import.

Installed to ~/.local/lib/music. Drives beets in-process (no subprocess,
no GUI) via its documented ImportSession.choose_match/choose_item hooks:
strong matches auto-import, everything else is simply left where it is
in the incoming dropzone for you to tag by hand (e.g. in Picard), then
picked up by a second `music-import --asis` pass that trusts whatever
tags are already on the file and just organizes it.

Safety model: files are only ever copied into the library, never moved
in place, and a source file is deleted only after the run completes and
its audio (STREAMINFO MD5) is verified to match a genuinely new file
under the library. beets silently no-ops the copy when it thinks a file
is a duplicate of something already in the library (leaves item.path
unchanged) -- that path is explicitly distinguished from success so a
"duplicate" never causes the only copy of a file to be deleted.
"""
import fcntl
import json
import os
import subprocess
import time
import urllib.parse
import urllib.request
from collections import Counter
from contextlib import contextmanager
from pathlib import Path

from beets import config, importer, autotag, plugins
from beets.library import Library

# Static settings (directory, copy/write/autotag, path layout) live in
# ~/.config/beets/config.yaml, loaded automatically by beets. MUSIC_ROOT
# only needs setting to redirect a test run at a sandbox instead of the
# real library.
_MUSIC_ROOT_OVERRIDE = os.environ.get('MUSIC_ROOT')
MUSIC_ROOT = None  # set by setup()
STATE = Path(os.environ.get('XDG_STATE_HOME', Path.home() / '.local' / 'state')) / 'music-import'
INCOMING = STATE / 'incoming'
BEETS_DB = STATE / 'beets' / 'library.db'
LOCK_FILE = STATE / 'lock'

HTTP_UA = 'music-import/1.0 (https://github.com/kamal-hamza/dotfiles)'

_loaded = False


def setup():
    if _MUSIC_ROOT_OVERRIDE:
        config['directory'] = _MUSIC_ROOT_OVERRIDE
    global MUSIC_ROOT
    MUSIC_ROOT = Path(config['directory'].as_filename())
    for d in (INCOMING, MUSIC_ROOT, BEETS_DB.parent):
        d.mkdir(parents=True, exist_ok=True)
    if subprocess.run(['which', 'metaflac'], capture_output=True).returncode != 0:
        raise SystemExit('metaflac not found on PATH')
    global _loaded
    if not _loaded:
        plugins.load_plugins()
        _loaded = True
    return Library(str(BEETS_DB), directory=str(MUSIC_ROOT))


@contextmanager
def lock(what='music-import'):
    LOCK_FILE.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(LOCK_FILE, os.O_CREAT | os.O_RDWR)
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise SystemExit(f'another {what} is already running')
    try:
        yield
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)
        os.close(fd)


def flac_md5(path):
    out = subprocess.run(['metaflac', '--show-md5sum', str(path)], capture_output=True, text=True)
    return out.stdout.strip()


def lrclib_lyrics(artist, title, album, duration):
    q = urllib.parse.urlencode({
        'artist_name': artist, 'track_name': title,
        'album_name': album or '', 'duration': int(duration or 0),
    })
    req = urllib.request.Request(f'https://lrclib.net/api/get?{q}', headers={'User-Agent': HTTP_UA})
    try:
        with urllib.request.urlopen(req, timeout=8) as r:
            data = json.loads(r.read())
        return data.get('syncedLyrics') or None
    except Exception:
        return None


class ImportSession(importer.ImportSession):
    """Auto-applies strong matches. In `asis` mode (files already hand-tagged
    in e.g. Picard), skips MusicBrainz entirely and trusts the existing tags.
    Anything else is left completely alone -- still sitting in incoming/,
    to be tagged by hand and picked up by a later asis pass."""

    def __init__(self, lib, paths, asis=False):
        super().__init__(lib, None, paths, None)
        self.asis = asis
        self.accepted = []  # list of (item, orig_path)

    def choose_match(self, task):
        orig = [i.path for i in task.items]
        if self.asis:
            self.accepted += [(i, o) for i, o in zip(task.items, orig)]
            return importer.Action.ASIS
        if task.rec == autotag.Recommendation.strong:
            self.accepted += [(i, o) for i, o in zip(task.items, orig)]
            return task.candidates[0]
        return importer.Action.SKIP

    def choose_item(self, task):
        if self.asis:
            self.accepted.append((task.item, task.item.path))
            return importer.Action.ASIS
        if task.rec == autotag.Recommendation.strong:
            self.accepted.append((task.item, task.item.path))
            return task.candidates[0]
        return importer.Action.SKIP


def _finish(sess, fetch_lyrics=False):
    """Verify + delete originals for accepted items.

    beets silently no-ops the file move when it decides an item is a
    duplicate of something already in the library (item.path is left
    unchanged). That must NOT be treated as success -- only delete a
    source once its audio is verified to exist, unchanged, at a
    genuinely new path under the library.
    """
    done = []
    stuck = []
    for item, orig in sess.accepted:
        op = orig.decode() if isinstance(orig, bytes) else orig
        np = item.path.decode() if isinstance(item.path, bytes) else item.path
        moved = np != op and np.startswith(str(MUSIC_ROOT) + os.sep)
        if moved and flac_md5(op) and flac_md5(op) == flac_md5(np):
            Path(op).unlink(missing_ok=True)
            if fetch_lyrics:
                lrc = lrclib_lyrics(item.artist, item.title, item.album, item.length)
                if lrc:
                    Path(np).with_suffix('.lrc').write_text(lrc)
            done.append(np)
        else:
            stuck.append(op)
    return done, stuck


PLACEHOLDER_ALBUMS = {'', 'unknown album', 'single', 'singles'}


def read_tags(path):
    out = subprocess.run(['metaflac', '--export-tags-to=-', str(path)], capture_output=True, text=True)
    tags = {}
    for line in out.stdout.splitlines():
        if '=' in line:
            k, v = line.split('=', 1)
            tags[k.lower()] = v
    return tags


def _album_key(path):
    """Many real-world rips/downloads carry junk album/albumartist tags
    (e.g. a random other artist's name, placeholder "Unknown Album").
    Album-tag-based grouping on that garbage silently lumps unrelated
    songs together (observed: 17 different artists' singles merged into
    one fake "album" because they all shared a stale ALBUMARTIST tag).
    Returns None for files with no usable album identity; only files
    that share a real (artist, album) key with at least one sibling go
    through album matching. A lone file with a "real" album tag is
    still matched as an independent track -- MusicBrainz recording
    search is a better fit for one file than release search.
    """
    tags = read_tags(path)
    album = tags.get('album', '').strip().lower()
    if album in PLACEHOLDER_ALBUMS:
        return None
    artist = (tags.get('albumartist') or tags.get('artist') or '').strip().lower()
    return (artist, album)


def _incoming_files():
    batch_dirs = [p for p in INCOMING.iterdir() if p.is_dir()]
    loose = [p for p in INCOMING.iterdir() if p.is_file() and p.suffix == '.flac']
    return batch_dirs, loose + [f for d in batch_dirs for f in sorted(d.glob('*.flac'))]


def _cleanup_empty_dirs(batch_dirs):
    for d in batch_dirs:
        try:
            d.rmdir()
        except OSError:
            pass


def _run_session(lib, paths, singletons, asis=False, fetch_lyrics=False):
    if not paths:
        return [], []
    config['import']['singletons'] = singletons
    config['import']['group_albums'] = not singletons
    sess = ImportSession(lib, paths, asis=asis)
    sess.run()
    return _finish(sess, fetch_lyrics=fetch_lyrics)


def run_import():
    """Auto-match against MusicBrainz; only strong (confident) matches are
    imported. Everything else is left untouched in incoming/ for you to
    tag by hand and pick up later with import_asis()."""
    lib = setup()
    batch_dirs, all_files = _incoming_files()

    keys = {f: _album_key(f) for f in all_files}
    group_sizes = Counter(k for k in keys.values() if k is not None)
    album_files = [f for f in all_files if keys[f] and group_sizes[keys[f]] >= 2]
    singleton_files = [f for f in all_files if f not in album_files]

    imported, stuck = [], []
    for files, singletons in ((album_files, False), (singleton_files, True)):
        i, s = _run_session(lib, [str(f).encode() for f in files], singletons)
        imported += i
        stuck += s

    _cleanup_empty_dirs(batch_dirs)
    left = len(_incoming_files()[1])
    return {'imported': len(imported), 'left': left, 'stuck': len(stuck)}


def import_asis():
    """Trust whatever tags are currently on files sitting in incoming/ (e.g.
    hand-tagged in Picard) -- no MusicBrainz search, just verify + organize.
    Everything is treated as singletons: files may span several unrelated
    albums/artists, and each file's own tags already say where it belongs.
    Files still missing basic artist/title tags are left alone rather than
    organized into a useless path -- there's nothing sane to name them."""
    lib = setup()
    batch_dirs, all_files = _incoming_files()
    ready = []
    for f in all_files:
        tags = read_tags(f)
        if tags.get('artist') and tags.get('title'):
            ready.append(f)
    imported, stuck = _run_session(lib, [str(f).encode() for f in ready], singletons=True, asis=True)
    _cleanup_empty_dirs(batch_dirs)
    left = len(_incoming_files()[1])
    return {'imported': len(imported), 'left': left, 'stuck': len(stuck)}


def _item_artists(item):
    """An item's individual contributing artists, e.g. ["Amaal Mallik",
    "Arijit Singh", "Aditi Singh Sharma"] for a collab track. Uses beets'
    parsed `artists` list (from MusicBrainz's artist-credit split), not the
    single joined `artist`/`albumartist` string ("Amaal Mallik, Arijit
    Singh & Aditi Singh Sharma") -- naively splitting that string on "&"/","
    would wrongly fragment duo/group names that legitimately contain those
    characters (e.g. "Simon & Garfunkel"). Falls back to the joined
    `artist` field whole for the rare item beets didn't parse a list for.
    """
    return list(item.artists) if item.artists else ([item.artist] if item.artist else [])


def list_artists():
    """Every individual artist credited on any track, deduped across
    however many collab tracks they appear on."""
    lib = setup()
    names = {name for item in lib.items() for name in _item_artists(item)}
    return sorted(names, key=str.lower)


def _artist_items(lib, artist):
    return [item for item in lib.items() if artist in _item_artists(item)]


def list_albums(artist):
    """Every album featuring `artist` (solo or collab), each with its
    track count and total duration, for the Library launcher mode's
    artist -> album drill-down."""
    lib = setup()
    albums = {}
    for item in _artist_items(lib, artist):
        key = item.album or 'Unknown Album'
        a = albums.setdefault(key, {'name': key, 'count': 0, 'totalSeconds': 0})
        a['count'] += 1
        a['totalSeconds'] += int(item.length or 0)
    return sorted(albums.values(), key=lambda a: a['name'].lower())


def artist_tracks(artist, album=None):
    """Paths (relative to MUSIC_ROOT, ready to hand to `mpc add`) for every
    track featuring `artist`, optionally scoped to one album -- this is
    what makes "play all of artist X" actually include every track they're
    a collaborator on, not just the ones where they're the sole/first
    credited artist."""
    lib = setup()
    items = _artist_items(lib, artist)
    if album is not None:
        items = [i for i in items if (i.album or 'Unknown Album') == album]
    items.sort(key=lambda i: (i.album or '', i.track or 0))
    paths = []
    for i in items:
        p = i.path.decode() if isinstance(i.path, bytes) else i.path
        paths.append(str(Path(p).relative_to(MUSIC_ROOT)))
    return paths


def list_all_albums():
    """Every (album, albumartist) release in the library, each with track
    count and total duration, for the Library launcher mode's flat Albums
    search - browsing/searching albums directly instead of drilling in
    through an artist first. Keyed on (album, albumartist) together, not
    album name alone, since two unrelated artists can share an album title
    (e.g. two different "Greatest Hits")."""
    lib = setup()
    albums = {}
    for item in lib.items():
        album = item.album or 'Unknown Album'
        artist = item.albumartist or item.artist or ''
        key = (album, artist)
        a = albums.setdefault(key, {'name': album, 'artist': artist, 'count': 0, 'totalSeconds': 0})
        a['count'] += 1
        a['totalSeconds'] += int(item.length or 0)
    return sorted(albums.values(), key=lambda a: (a['name'].lower(), a['artist'].lower()))


def album_tracks(album, artist):
    """Paths (relative to MUSIC_ROOT) for every track in one (album,
    albumartist) release, for the flat Albums view's direct play."""
    lib = setup()
    items = [i for i in lib.items()
             if (i.album or 'Unknown Album') == album and (i.albumartist or i.artist or '') == artist]
    items.sort(key=lambda i: i.track or 0)
    paths = []
    for i in items:
        p = i.path.decode() if isinstance(i.path, bytes) else i.path
        paths.append(str(Path(p).relative_to(MUSIC_ROOT)))
    return paths


def backfill_lyrics():
    """Fetch .lrc lyrics for any FLAC in the library that doesn't have one
    yet. Safe to run anytime, independent of importing."""
    fetched = 0
    checked = 0
    for flac in MUSIC_ROOT.rglob('*.flac'):
        lrc = flac.with_suffix('.lrc')
        if lrc.exists():
            continue
        checked += 1
        tags = read_tags(flac)
        artist, title, album = tags.get('artist', ''), tags.get('title', ''), tags.get('album', '')
        if not (artist and title):
            continue
        out = subprocess.run(['metaflac', '--show-total-samples', '--show-sample-rate', str(flac)],
                              capture_output=True, text=True).stdout.split()
        duration = int(out[0]) / int(out[1]) if len(out) == 2 and int(out[1]) else 0
        lyrics = lrclib_lyrics(artist, title, album, duration)
        if lyrics:
            lrc.write_text(lyrics)
            fetched += 1
    return {'checked': checked, 'fetched': fetched}


MB_API = 'https://musicbrainz.org/ws/2'
# MusicBrainz asks for >=1s between requests from an unauthenticated client;
# leave headroom since we're calling this directly, not through beets'
# already-compliant, self-throttling HTTP client.
_MB_INTERVAL = 1.1
_BAD_SECONDARY_TYPES = {'Compilation', 'Live', 'Soundtrack', 'Remix', 'DJ-mix', 'Mixtape/Street'}


def _mb_get(path, params):
    q = urllib.parse.urlencode(params)
    req = urllib.request.Request(f'{MB_API}/{path}?{q}', headers={'User-Agent': HTTP_UA})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read())


def _pick_release(releases):
    """Best-guess "real" album for a recording that beets only ever matched
    as a standalone singleton. A recording is usually attached to many
    releases (reissues, regional editions, compilations, best-ofs); prefer
    an official studio album over a single, and prefer a single over a
    compilation/live/soundtrack appearance, then take the earliest release
    in the best tier -- that's usually the original album it was written for.
    """
    releases = [r for r in releases if r.get('title')]
    if not releases:
        return None

    def rank(rel):
        rg = rel.get('release-group') or {}
        primary = rg.get('primary-type')
        secondary = set(rg.get('secondary-types') or [])
        official = rel.get('status') == 'Official'
        clean_album = primary == 'Album' and not (secondary & _BAD_SECONDARY_TYPES)
        if official and clean_album:
            tier = 0
        elif official and primary == 'Single':
            tier = 1
        elif clean_album:
            tier = 2
        else:
            tier = 3
        return (tier, rel.get('date') or '9999')

    return sorted(releases, key=rank)[0]


def fix_album_tags(dry_run=False):
    """Resolve a real album for library tracks stuck on a placeholder album
    (e.g. "Unknown Album") after being matched as standalone singletons.
    Uses each track's own MUSICBRAINZ_TRACKID (already set by the earlier
    import) to look up its releases on MusicBrainz and picks the most
    likely original album -- see _pick_release. Writes through beets'
    Item API so both the file tags and beets' own library DB (which the
    Library launcher reads from) end up in sync. Never moves/renames files,
    so playlist paths stay valid."""
    lib = setup()
    fixed, skipped, checked = 0, 0, 0
    for item in lib.items():
        album = (item.album or '').strip().lower()
        if album not in PLACEHOLDER_ALBUMS:
            continue
        mbid = item.mb_trackid
        if not mbid:
            skipped += 1
            continue
        checked += 1
        try:
            data = _mb_get(f'recording/{mbid}', {'inc': 'releases+release-groups', 'fmt': 'json'})
        except Exception:
            skipped += 1
            time.sleep(_MB_INTERVAL)
            continue
        time.sleep(_MB_INTERVAL)
        release = _pick_release(data.get('releases') or [])
        if not release:
            skipped += 1
            continue
        credits = release.get('artist-credit') or []
        artist_name = ''.join(c.get('name', '') + c.get('joinphrase', '') for c in credits) or item.artist
        if dry_run:
            print(f'{item.artist} - {item.title}: -> {release["title"]!r} / {artist_name!r}')
            fixed += 1
            continue
        item.album = release['title']
        item.albumartist = artist_name
        item.mb_albumid = release.get('id', '')
        item.mb_releasegroupid = (release.get('release-group') or {}).get('id', '')
        item.try_sync(write=True, move=False)
        fixed += 1
    return {'checked': checked, 'fixed': fixed, 'skipped': skipped}
