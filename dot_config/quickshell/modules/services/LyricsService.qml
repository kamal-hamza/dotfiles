pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Synced-lyrics preview for the currently playing track, sourced from the
// .lrc sidecars that executable_music-lyrics/music-import already backfill
// next to each FLAC under ~/Music (fetched from LRCLib.net - see
// musiclib.py's lrclib_lyrics()). No network call happens here, just a
// local file read - and since that helper only ever writes `syncedLyrics`,
// every .lrc this reads is guaranteed to carry per-line timestamps.
// Falls back to the FLAC's embedded LYRICS tag when no sidecar exists
// (see _readEmbedded()).
//
// MPRIS metadata has no local file path for MPD (mpd-mpris doesn't publish
// xesam:url), so the path comes from `mpc current -f %file%` instead - the
// same tool this shell's keybindings already drive MPD with (see
// keymaps.lua). Lyrics are therefore only ever available while
// MediaService.isMpd is true; other players (browsers, etc.) have no local
// sidecar to read.
// (MediaService is a sibling singleton in this same directory, so it's
// already visible here without an explicit import.)
//
// Line sync uses MediaService.position, which for MPD is already polled
// from `mpc status` rather than trusting MPRIS (see the comment there).

QtObject {
    id: root

    readonly property string musicRoot: Quickshell.env("HOME") + "/Music/"

    // Folds MediaService.isMpd into the key so switching to/from a
    // non-MPD player also triggers a refresh even if title/artist happen
    // to coincide.
    readonly property string trackKey: (MediaService.isMpd ? "mpd::" : "other::")
        + MediaService.trackArtist + "::" + MediaService.trackTitle + "::" + MediaService.trackAlbum

    property string _relPath: ""
    // [{ t: seconds, text: "..." }], ascending by t.
    property var lines: []
    readonly property bool hasLyrics: root.lines.length > 0

    onTrackKeyChanged: root._refresh()
    Component.onCompleted: root._refresh()

    function _refresh() {
        root.lines = [];
        root._relPath = "";
        if (!MediaService.isMpd) return;
        _mpcProc.running = true;
    }

    property Process _mpcProc: Process {
        command: ["mpc", "current", "-f", "%file%"]
        stdout: StdioCollector {
            onStreamFinished: {
                const rel = text.trim();
                if (rel) root._relPath = rel;
            }
        }
    }

    readonly property string _lrcPath: root._relPath === "" ? ""
        : root.musicRoot + root._relPath.replace(/\.[^./]+$/, ".lrc")

    property FileView _lrcFile: FileView {
        path: root._lrcPath
        printErrors: false
        watchChanges: false
        onLoaded: root._parse(_lrcFile.text())
        onLoadFailed: root._readEmbedded()
    }

    // Fallback when there's no sidecar (e.g. a tagger like Picard renamed
    // the FLAC but left its .lrc behind under the old name): read the
    // LYRICS Vorbis comment embedded in the file itself. Only synced
    // lyrics survive _parse(), same as for sidecars.
    function _readEmbedded() {
        root.lines = [];
        if (root._relPath === "") return;
        _embeddedProc.command = ["metaflac", "--show-tag=LYRICS", root.musicRoot + root._relPath];
        _embeddedProc.running = true;
    }

    property Process _embeddedProc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                // Stale result from a previous track - _refresh() already moved on.
                if (_embeddedProc.command[2] !== root.musicRoot + root._relPath) return;
                // metaflac prints "LYRICS=<value>" with any newlines in the
                // value emitted verbatim, so only the first line has the prefix.
                root._parse(text.replace(/^LYRICS=/i, ""));
            }
        }
    }

    // LRC is "[mm:ss.cc] text" per line; anything without a leading
    // timestamp is skipped (musiclib.py never writes plain lyrics, so this
    // only ever ignores stray metadata lines, not real content).
    function _parse(raw) {
        const out = [];
        const rawLines = String(raw).split("\n");
        for (let i = 0; i < rawLines.length; i++) {
            const m = rawLines[i].match(/^\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)$/);
            if (!m) continue;
            out.push({ t: Number(m[1]) * 60 + Number(m[2]), text: m[3] });
        }
        out.sort((a, b) => a.t - b.t);
        root.lines = out;
    }

    // Index of the line active at `pos` seconds, or -1 before the first line.
    function lineIndexForPosition(pos) {
        let found = -1;
        for (let i = 0; i < root.lines.length; i++) {
            if (root.lines[i].t <= pos) found = i;
            else break;
        }
        return found;
    }

    function lineTextAt(index) {
        if (index < 0 || index >= root.lines.length) return "";
        return root.lines[index].text;
    }
}
