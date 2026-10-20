pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Shared MPRIS player-selection logic, used by both NowPlaying.qml (pill)
// and NowPlayingPopup.qml so the precedence/filtering rules live in exactly
// one place.
//
// On top of the usual playing > paused > first precedence, MPD (bridged
// onto MPRIS via mpd-mpris) always wins whenever it's actually playing -
// mirroring waybar's media.sh script, which checks mpc before falling back
// to playerctl. MPD is this machine's real music setup (see the mpc-based
// bindings in keymaps.lua); everything else is secondary.
QtObject {
    id: root

    // playerctld (if running) publishes a virtual player that mirrors
    // whichever real player is currently active. Without filtering it out,
    // every real player shows up twice.
    readonly property var players: {
        const all = Mpris.players ? Mpris.players.values : [];
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const p = all[i];
            if (!p) continue;
            if ((p.dbusName || "").indexOf("playerctld") >= 0) continue;
            out.push(p);
        }
        return out;
    }

    function _isMpd(p) {
        if (!p) return false;
        const name = ((p.dbusName || "") + (p.identity || "") + (p.desktopEntry || "")).toLowerCase();
        return name.indexOf("mpd") >= 0;
    }

    readonly property var currentPlayer: {
        const list = root.players;
        if (list.length === 0) return null;

        const mpd = list.find(p => root._isMpd(p));

        // MPD wins outright whenever it's actually playing.
        if (mpd && mpd.playbackState === MprisPlaybackState.Playing) return mpd;

        for (let i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Playing) return list[i];
        }

        // A paused MPD track still outranks a merely-present (paused/idle)
        // other player.
        if (mpd && mpd.playbackState === MprisPlaybackState.Paused) return mpd;

        for (let i = 0; i < list.length; i++) {
            if (list[i].playbackState === MprisPlaybackState.Paused) return list[i];
        }

        return mpd || list[0];
    }

    // A Stopped player (e.g. MPD after `mpc clear` empties the queue) keeps
    // reporting its last track's metadata on the bus instead of clearing it
    // - treat Stopped the same as "no player" so the UI falls back to
    // "Nothing playing" instead of showing a stale track.
    readonly property bool hasPlayer: root.currentPlayer !== null
        && root.currentPlayer.playbackState !== MprisPlaybackState.Stopped
    readonly property bool isPlaying: root.hasPlayer && root.currentPlayer.playbackState === MprisPlaybackState.Playing

    // Exposed for LyricsService: MPRIS carries no local file path for MPD
    // (mpd-mpris doesn't publish xesam:url), so lyrics have to be looked up
    // via `mpc` instead - which only makes sense when MPD is actually the
    // current player.
    readonly property bool isMpd: root.hasPlayer && root._isMpd(root.currentPlayer)

    readonly property string trackTitle: root.hasPlayer ? (root.currentPlayer.trackTitle || "Untitled") : ""
    readonly property string trackArtist: root.hasPlayer ? (root.currentPlayer.trackArtist || "") : ""
    readonly property string trackAlbum: root.hasPlayer ? (root.currentPlayer.trackAlbum || "") : ""
    // trackAlbum minus MusicBrainz/Picard's bracketed placeholder "albums"
    // ("[standalone recordings]", "[non-album tracks]") - those aren't a
    // real release, so UI shouldn't present them as one.
    readonly property string displayAlbum: /^\[.*\]$/.test(root.trackAlbum.trim()) ? "" : root.trackAlbum

    readonly property bool canGoNext: root.hasPlayer && root.currentPlayer.canGoNext
    readonly property bool canGoPrevious: root.hasPlayer && root.currentPlayer.canGoPrevious
    readonly property bool canTogglePlaying: root.hasPlayer && root.currentPlayer.canTogglePlaying
    readonly property bool canSeek: root.hasPlayer && root.currentPlayer.canSeek

    // For MPD, position/length come from `mpc status` rather than MPRIS:
    // Quickshell's MprisPlayer only re-reads Position on a Seeked signal
    // and otherwise extrapolates from its last value, and mpd-mpris doesn't
    // send Seeked on a plain track change - so after switching songs the
    // MPRIS position keeps counting from wherever the previous track was
    // (observed: 5:23 elapsed on a 3:45 track) until the next manual seek.
    // mpc talks to mpd directly. Polled from tickProgress(), same
    // lifecycle callers already use.
    readonly property real position: !root.hasPlayer ? 0
        : root.isMpd ? root._mpdPosition
        : root.currentPlayer.position
    readonly property real length: !root.hasPlayer ? 0
        : (root.isMpd && root._mpdLength > 0) ? root._mpdLength
        : root.currentPlayer.length

    // `mpc status` only has whole seconds, so between polls the position is
    // extrapolated from when that whole-second value last changed (capped
    // at 1s so a missed poll can't run it ahead).
    property real _mpdElapsed: 0
    property real _mpdLength: 0
    property real _mpdStamp: 0
    property real _now: 0
    readonly property real _mpdPosition: root.isPlaying
        ? root._mpdElapsed + Math.max(0, Math.min(1, (root._now - root._mpdStamp) / 1000))
        : root._mpdElapsed

    function _resetMpd() {
        root._mpdElapsed = 0;
        root._mpdLength = 0;
        root._mpdStamp = Date.now();
        root._pollMpd();
    }

    function _pollMpd() {
        if (root.isMpd && !_mpcStatusProc.running) _mpcStatusProc.running = true;
    }

    property Process _mpcStatusProc: Process {
        command: ["mpc", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Second line looks like "[playing] #1/2   0:54/4:50 (18%)".
                const m = text.match(/(\d+):(\d+)\/(\d+):(\d+)/);
                if (!m) return;
                const elapsed = Number(m[1]) * 60 + Number(m[2]);
                if (elapsed !== root._mpdElapsed) {
                    root._mpdElapsed = elapsed;
                    root._mpdStamp = Date.now();
                }
                root._mpdLength = Number(m[3]) * 60 + Number(m[4]);
            }
        }
    }

    // Last non-empty album art URL for the current player. Browsers (and
    // some other MPRIS players) intermittently emit an empty trackArtUrl on
    // pause/unpause without the art actually changing - caching the last
    // real value avoids flashing a blank cover during those gaps.
    property string cachedArtUrl: ""

    function _refreshArt() {
        if (root.currentPlayer && root.currentPlayer.trackArtUrl)
            root.cachedArtUrl = root.currentPlayer.trackArtUrl;
    }

    onCurrentPlayerChanged: {
        root.cachedArtUrl = "";
        root._refreshArt();
        root._resetMpd();
    }
    onIsMpdChanged: root._resetMpd()

    Component.onCompleted: root._refreshArt()

    property Connections _playerWatcher: Connections {
        target: root.currentPlayer
        enabled: root.currentPlayer !== null
        function onTrackChanged() {
            root.cachedArtUrl = "";
            root._refreshArt();
            root._resetMpd();
        }
        function onPlaybackStateChanged() {
            root._pollMpd();
        }
        function onTrackArtUrlChanged() {
            root._refreshArt();
        }
    }

    // Neither MprisPlayer.position nor the mpc-polled MPD position is
    // reactive on its own - call this periodically (e.g. from a Timer while
    // a popup is open) to force a re-read so the elapsed-time readout moves
    // smoothly.
    function tickProgress() {
        root._now = Date.now();
        if (root.isMpd) root._pollMpd();
        else if (root.currentPlayer) root.currentPlayer.positionChanged();
    }

    function togglePlay() {
        if (root.currentPlayer && root.currentPlayer.canTogglePlaying) root.currentPlayer.togglePlaying();
    }
    function stop() {
        if (root.currentPlayer) root.currentPlayer.stop();
    }
    function next() {
        if (root.currentPlayer && root.currentPlayer.canGoNext) root.currentPlayer.next();
    }
    function previous() {
        if (root.currentPlayer && root.currentPlayer.canGoPrevious) root.currentPlayer.previous();
    }
    function seek(positionSeconds) {
        if (!root.currentPlayer || !root.currentPlayer.canSeek) return;
        root.currentPlayer.position = positionSeconds;
        if (root.isMpd) {
            // Show the new spot immediately; the next poll confirms it.
            root._mpdElapsed = Math.floor(positionSeconds);
            root._mpdStamp = Date.now();
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0 || isNaN(seconds)) return "0:00";
        const total = Math.floor(seconds);
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" + s : s);
    }
}
