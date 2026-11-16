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


def prune_missing(lib):
    """Drop library rows whose file is gone from disk (deleted by hand).
    Without this, beets' duplicate check still sees the ghost row and
    silently skips re-importing that track. Rows only -- never touches
    files. Skipped when MUSIC_ROOT is empty, so an unmounted music drive
    can't wipe the whole library."""
    if not any(MUSIC_ROOT.iterdir()):
        return 0
    gone = [i for i in lib.items() if not os.path.exists(i.path)]
    for item in gone:
        item.remove(delete=False)
    return len(gone)


# beets (via mediafile) reads several Vorbis keys per field and takes the
# FIRST present -- and for these fields that's an alias, not the key Picard
# writes. beets writes every alias whenever it saves a file, Picard then
# updates only its own key, and from then on the stale alias shadows every
# Picard edit (observed: ALBUM ARTIST still holding the downloader's value,
# DISC=0 next to DISCNUMBER=1). Picard's key -> the aliases read before it.
_SHADOWING_ALIASES = {
    'ALBUMARTIST': ('ALBUM ARTIST', 'ALBUM_ARTIST'),
    'TRACKNUMBER': ('TRACK',),
    'DISCNUMBER': ('DISC',),
}


def reconcile_tags(items, dry_run=False):
    """Drop aliases that disagree with Picard's key for the same field, so
    beets reads what Picard wrote. Only touches tags, never audio (the
    STREAMINFO MD5 playlists key on is unchanged). Returns files changed."""
    import mutagen.flac
    changed = 0
    for item in items:
        path = item.path.decode() if isinstance(item.path, bytes) else item.path
        if not path.lower().endswith('.flac'):
            continue
        f = mutagen.flac.FLAC(path)
        if f.tags is None:
            continue
        stale = [alias for key, aliases in _SHADOWING_ALIASES.items() if f.tags.get(key)
                 for alias in aliases if f.tags.get(alias) and f.tags.get(alias) != f.tags.get(key)]
        if not stale:
            continue
        changed += 1
        if not dry_run:
            for alias in stale:
                del f.tags[alias]
            f.save()
    return changed


def refresh_library(lib, dry_run=False):
    """Make beets' DB match the tags on disk (the files are the source of
    truth -- they're kept up to date in Picard), via beets' own `update`
    logic, after reconcile_tags() has cleared aliases that would hide
    Picard's values. Re-reads every file rather than trusting mtimes, since
    Picard can preserve timestamps when saving. Returns the number of
    tracks whose DB row changed. Never moves/renames files. Missing files
    are left to prune_missing(), which guards against an unmounted music
    dir; update_items() would happily drop every row."""
    from beets.ui.commands.update import update_items
    items = [i for i in lib.items() if os.path.exists(i.path)]
    if not items:
        return 0
    reconcile_tags(items, dry_run=dry_run)
    before = {i.id: dict(i) for i in items}
    for i in items:
        i.mtime = 0  # force update_items() to re-read every file
    update_items(lib, items, move=False, pretend=dry_run, fields=None)
    if dry_run:
        return sum(1 for i in items if any(i.get(k) != v for k, v in before[i.id].items() if k != 'mtime'))
    return sum(1 for i in lib.items() if i.id in before
               and any(i.get(k) != v for k, v in before[i.id].items() if k != 'mtime'))


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
    sync_playlists()  # snapshot playlist identities before any path can change
    pruned = prune_missing(lib)
    refresh_library(lib)
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
    refresh_library(lib)
    playlists = sync_playlists()
    return {'imported': len(imported), 'left': left, 'stuck': len(stuck), 'pruned': pruned, 'playlists': playlists}


def import_asis():
    """Trust whatever tags are currently on files sitting in incoming/ (e.g.
    hand-tagged in Picard) -- no MusicBrainz search, just verify + organize.
    Everything is treated as singletons: files may span several unrelated
    albums/artists, and each file's own tags already say where it belongs.
    Files still missing basic artist/title tags are left alone rather than
    organized into a useless path -- there's nothing sane to name them."""
    lib = setup()
    sync_playlists()  # snapshot playlist identities before any path can change
    pruned = prune_missing(lib)
    refresh_library(lib)
    batch_dirs, all_files = _incoming_files()
    ready = []
    for f in all_files:
        tags = read_tags(f)
        if tags.get('artist') and tags.get('title'):
            ready.append(f)
    imported, stuck = _run_session(lib, [str(f).encode() for f in ready], singletons=True, asis=True)
    _cleanup_empty_dirs(batch_dirs)
    left = len(_incoming_files()[1])
    refresh_library(lib)
    playlists = sync_playlists()
    return {'imported': len(imported), 'left': left, 'stuck': len(stuck), 'pruned': pruned, 'playlists': playlists}


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
    if not dry_run:
        sync_playlists()
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
    if not dry_run:
        sync_playlists()
    return {'checked': checked, 'fixed': fixed, 'skipped': skipped}


# MPD's saved playlists (`mpc save`, ncmpcpp's playlist editor) are plain
# .m3u files of paths relative to MUSIC_ROOT -- the moment a file is renamed
# (Picard's "rename files", a beets path format change, a library rebuild),
# every playlist entry pointing at it silently dies. MPD rewrites these
# files itself on every edit, dropping anything that isn't a bare path, so
# the stable identity of each entry lives in a sidecar manifest per playlist
# instead. sync_playlists() keeps that manifest fresh for every entry that
# still resolves and uses it to re-point entries that don't.
#
# Identity is read from the files on disk, never the beets DB: Picard
# renames and retags files behind beets' back, so the DB's paths and tags
# can be stale. In order of trust:
#   1. FLAC STREAMINFO audio MD5 -- a hash of the decoded audio itself, so
#      it survives any rename and any tag edit; changes only if the audio
#      is replaced.
#   2. MusicBrainz recording id (MUSICBRAINZ_TRACKID) -- survives swapping
#      in a different rip/master of the same recording.
#   3. artist + title -- only for entries that predate their manifest.
PLAYLIST_DIR = Path(os.environ.get('MPD_PLAYLIST_DIR', Path.home() / '.config' / 'mpd' / 'playlists'))
PLAYLIST_MANIFESTS = STATE / 'playlists'
_AUDIO_EXTS = {'.flac', '.mp3', '.m4a', '.ogg', '.opus'}


def _norm(s):
    """Loose match key: case-, punctuation- and whitespace-insensitive, so
    filesystem-sanitized names ("R.E.M_", odd unicode hyphens) still match
    their tags."""
    return ''.join(c for c in (s or '').casefold() if c.isalnum())


def _scan_library():
    """One identity record per audio file under MUSIC_ROOT, straight from
    its own tags/stream info. Cheap: mutagen only reads the header blocks."""
    import mutagen
    records = []
    for path in sorted(MUSIC_ROOT.rglob('*')):
        if path.suffix.lower() not in _AUDIO_EXTS or not path.is_file():
            continue
        try:
            f = mutagen.File(path, easy=True)
        except Exception:
            continue
        if f is None:
            continue
        tags = f.tags or {}
        first = lambda k: (tags.get(k) or [''])[0]
        md5 = getattr(f.info, 'md5_signature', 0)
        records.append({
            'path': str(path.relative_to(MUSIC_ROOT)),
            'md5': f'{md5:032x}' if md5 else '',
            'mbid': first('musicbrainz_trackid'),
            'artist': first('artist'),
            'title': first('title'),
            'artists': tags.get('artists') or [],
        })
    return records


def _path_guess(rel):
    """(artist, title) guessed from a dead path's own shape -- the fallback
    for entries that predate their manifest. Covers the layouts this library
    has used: "<Artist>/<Title>.flac" and "<Artist>/<NN> [<Artist> - ]<Title>.flac"."""
    p = Path(rel)
    stem = p.stem
    head, _, rest = stem.partition(' ')
    if rest and head.replace('-', '').isdigit():
        stem = rest
    artist = p.parent.name
    if stem.startswith(artist + ' - '):
        stem = stem[len(artist) + 3:]
    return artist, stem


def _resolver(records):
    by_path, by_md5, by_mbid, by_artist_title, by_title, by_dir = {}, {}, {}, {}, {}, {}
    for r in records:
        by_path[r['path']] = r
        if r['md5']:
            by_md5.setdefault(r['md5'], r)
        if r['mbid']:
            by_mbid.setdefault(r['mbid'], r)
        t = _norm(r['title'])
        for a in {r['artist'], *r['artists']}:
            by_artist_title.setdefault((_norm(a), t), r)
        by_title.setdefault(t, []).append(r)
        by_dir.setdefault(str(Path(r['path']).parent), []).append(r)

    def resolve(rel, rec):
        if rec and rec.get('md5') in by_md5:
            return by_md5[rec['md5']]
        if rec and rec.get('mbid') in by_mbid:
            return by_mbid[rec['mbid']]
        guesses = [(rec['artist'], rec['title'])] if rec and rec.get('title') else []
        guesses.append(_path_guess(rel))
        for artist, title in guesses:
            hit = by_artist_title.get((_norm(artist), _norm(title)))
            if hit:
                return hit
        # Retagged with a suffix ("X (Title Track)", "X - with Y") but still
        # in the same artist folder -- only if exactly one track there fits.
        for _, title in guesses:
            t = _norm(title)
            hits = [r for r in by_dir.get(str(Path(rel).parent), []) if t and _norm(r['title']).startswith(t)]
            if len(hits) == 1:
                return hits[0]
        # Last resort: a title that exists exactly once in the whole library.
        for _, title in guesses:
            hits = by_title.get(_norm(title), [])
            if len(hits) == 1:
                return hits[0]
        return None

    return by_path, resolve


def _manifest_record(r):
    return {k: r[k] for k in ('path', 'md5', 'mbid', 'artist', 'title')}


def _write_atomic(path, text):
    tmp = path.with_name(f'.{path.name}.tmp')
    tmp.write_text(text)
    os.replace(tmp, path)


def sync_playlists(dry_run=False):
    """Repair every MPD playlist's dead paths from its manifest, then refresh
    the manifest from whatever now resolves. Safe to run anytime; entries
    that can't be resolved are kept as-is (MPD just skips them) along with
    their last known identity, so they heal if the track comes back."""
    if MUSIC_ROOT is None:
        setup()
    if not PLAYLIST_DIR.is_dir():
        return {'playlists': 0, 'repaired': 0, 'unresolved': []}
    PLAYLIST_MANIFESTS.mkdir(parents=True, exist_ok=True)
    by_path, resolve = _resolver(_scan_library())
    repaired, unresolved, count = 0, [], 0
    for m3u in sorted(PLAYLIST_DIR.glob('*.m3u')):
        count += 1
        manifest = PLAYLIST_MANIFESTS / f'{m3u.stem}.json'
        try:
            old = {r['path']: r for r in json.loads(manifest.read_text())}
        except (OSError, ValueError):
            old = {}
        entries = [l for l in m3u.read_text().splitlines() if l.strip() and not l.startswith('#')]
        out, records = [], []
        for rel in entries:
            r = by_path.get(rel)
            if r is None:
                r = resolve(rel, old.get(rel))
                if r is None:
                    unresolved.append(f'{m3u.stem}: {rel}')
                    out.append(rel)
                    records.append(old.get(rel) or {'path': rel})
                    continue
                repaired += 1
            out.append(r['path'])
            records.append(_manifest_record(r))
        if dry_run:
            continue
        if out != entries:
            _write_atomic(m3u, ''.join(f'{p}\n' for p in out))
        _write_atomic(manifest, json.dumps(records, indent=1, ensure_ascii=False) + '\n')
    return {'playlists': count, 'repaired': repaired, 'unresolved': unresolved}
