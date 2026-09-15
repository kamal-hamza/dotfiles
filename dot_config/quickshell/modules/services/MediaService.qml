pragma Singleton
import QtQuick
import Quickshell
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

    readonly property bool hasPlayer: root.currentPlayer !== null
    readonly property bool isPlaying: root.hasPlayer && root.currentPlayer.playbackState === MprisPlaybackState.Playing

    readonly property string trackTitle: root.hasPlayer ? (root.currentPlayer.trackTitle || "Untitled") : ""
    readonly property string trackArtist: root.hasPlayer ? (root.currentPlayer.trackArtist || "") : ""
    readonly property string trackAlbum: root.hasPlayer ? (root.currentPlayer.trackAlbum || "") : ""

    readonly property bool canGoNext: root.hasPlayer && root.currentPlayer.canGoNext
    readonly property bool canGoPrevious: root.hasPlayer && root.currentPlayer.canGoPrevious
    readonly property bool canTogglePlaying: root.hasPlayer && root.currentPlayer.canTogglePlaying
    readonly property bool canSeek: root.hasPlayer && root.currentPlayer.canSeek

    readonly property real position: root.hasPlayer ? root.currentPlayer.position : 0
    readonly property real length: root.hasPlayer ? root.currentPlayer.length : 0

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
    }

    Component.onCompleted: root._refreshArt()

    property Connections _playerWatcher: Connections {
        target: root.currentPlayer
        enabled: root.currentPlayer !== null
        function onTrackChanged() {
            root.cachedArtUrl = "";
            root._refreshArt();
        }
        function onTrackArtUrlChanged() {
            root._refreshArt();
        }
    }

    // MprisPlayer.position isn't reactive on its own - call this
    // periodically (e.g. from a Timer while a popup is open) to force a
    // re-read so the elapsed-time readout moves smoothly.
    function tickProgress() {
        if (root.currentPlayer) root.currentPlayer.positionChanged();
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
        if (root.currentPlayer && root.currentPlayer.canSeek) root.currentPlayer.position = positionSeconds;
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0 || isNaN(seconds)) return "0:00";
        const total = Math.floor(seconds);
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" + s : s);
    }
}
