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
// Playback position for line sync is *also* polled from `mpc status`
// (root.position, via pollPosition()) instead of MediaService.position:
// mpd-mpris doesn't reliably refresh MPRIS's Position at track-change
// boundaries - it's been observed reporting a stale value carried over
// from whichever track played before, sometimes for the entire length of
// the new track, until an explicit seek forces a hard resync. `mpc
// status` talks to mpd directly and doesn't have that problem.

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
        root.position = 0;
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
        onLoadFailed: root.lines = []
    }

    // Ground-truth elapsed seconds, refreshed on demand - call this from a
    // Timer while the lyrics panel is actually visible (see
    // NowPlayingPopup.qml), same lifecycle MediaService.tickProgress()
    // already uses for the ordinary progress bar.
    property real position: 0

    property Process _statusProc: Process {
        command: ["mpc", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Second line looks like "[playing] #1/2   0:54/4:50 (18%)".
                const m = text.match(/(\d+):(\d+)\/\d+:\d+/);
                if (m) root.position = Number(m[1]) * 60 + Number(m[2]);
            }
        }
    }

    function pollPosition() {
        if (MediaService.isMpd) _statusProc.running = true;
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
