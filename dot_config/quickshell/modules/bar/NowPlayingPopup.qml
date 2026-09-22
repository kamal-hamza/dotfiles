import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../theme"
import "../common"
import "../services"

// Body shown from the now-playing pill: album art, track info, an optional
// synced-lyrics preview (LyricsService - only ever populated for MPD, see
// that file), round prev/play-pause/next buttons and a seekable progress
// bar - all driven by MediaService (native MPRIS), matching the pill.
PopupCard {
    id: popup

    cardWidth: 300

    // Sticky across tracks by design - if the next track also has lyrics,
    // reopening the panel every time would be more annoying than leaving it
    // expanded. It simply has nothing to show (LyricsToggle hides itself)
    // when the current track has none.
    property bool showLyrics: false

    // MprisPlayer.position isn't reactive on its own - force a re-read
    // periodically while the popup is visible and something is playing, so
    // the progress bar and elapsed-time readout move smoothly instead of
    // only updating on track/seek events. Lyric sync deliberately does NOT
    // use MediaService.position here (see LyricsService's header comment) -
    // it polls mpd directly instead, since mpd-mpris can report a stale
    // MPRIS position right after a track change until the next seek.
    Timer {
        interval: 250
        repeat: true
        running: popup.visible && MediaService.isPlaying
        onTriggered: {
            MediaService.tickProgress();
            LyricsService.pollPosition();
        }
    }

    readonly property real progress: MediaService.length > 0
        ? Math.max(0, Math.min(1, MediaService.position / MediaService.length)) : 0

    readonly property int currentLyricIndex: LyricsService.lineIndexForPosition(LyricsService.position)

    component RoundButton: Rectangle {
        id: btn
        property string glyph: ""
        property bool primary: false
        signal clicked()

        width: primary ? 46 : 34
        height: width
        radius: width / 2
        color: primary ? Theme.emphasis : (btnMa.containsMouse ? Theme.bgHover : "transparent")
        border.width: primary ? 0 : 1
        border.color: Theme.border
        opacity: btn.enabled ? 1 : 0.35

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            font.family: Theme.fontFamily
            font.pixelSize: btn.primary ? Theme.font.lg : Theme.font.md
            color: btn.primary ? Theme.textOnEmphasis : Theme.textPrimary
        }

        MouseArea {
            id: btnMa
            anchors.fill: parent
            enabled: btn.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    // Small pill toggle, distinct from RoundButton since this sits inline
    // with text rather than in the transport row.
    component LyricsToggle: Rectangle {
        id: toggle
        property bool active: false
        signal clicked()

        implicitHeight: 22
        implicitWidth: label.implicitWidth + Theme.spacing.md * 2
        radius: height / 2
        color: toggle.active ? Theme.emphasis : (toggleMa.containsMouse ? Theme.bgHover : "transparent")
        border.width: toggle.active ? 0 : 1
        border.color: Theme.border

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Text {
            id: label
            anchors.centerIn: parent
            text: "Lyrics"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            color: toggle.active ? Theme.textOnEmphasis : Theme.textSecondary
        }

        MouseArea {
            id: toggleMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.clicked()
        }
    }

    ClippingRectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 128
        height: 128
        radius: width / 2
        color: Theme.bgControl

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
            source: MediaService.cachedArtUrl
        }

        Text {
            anchors.centerIn: parent
            visible: MediaService.cachedArtUrl === ""
            text: "󰎈" // nf-md-music_note
            font.family: Theme.fontFamily
            font.pixelSize: 40
            color: Theme.textTertiary
        }
    }

    Column {
        width: parent.width
        spacing: 4

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: MediaService.hasPlayer ? MediaService.trackTitle : "Nothing playing"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.lg
            font.bold: true
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: MediaService.trackArtist.length > 0
            text: MediaService.trackArtist
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: MediaService.trackAlbum.length > 0
            text: MediaService.trackAlbum
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            color: Theme.textTertiary
        }
    }

    LyricsToggle {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: LyricsService.hasLyrics
        active: popup.showLyrics
        onClicked: popup.showLyrics = !popup.showLyrics
    }

    // Prev/current/next synced line, centered on whatever LyricsService
    // resolved for the current playback position. Only ever shown for MPD
    // tracks that have a local .lrc sidecar (see LyricsService) - other
    // players just never make the toggle above visible.
    Column {
        width: parent.width
        spacing: 2
        visible: popup.showLyrics && LyricsService.hasLyrics

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: LyricsService.lineTextAt(popup.currentLyricIndex - 1)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            color: Theme.textTertiary
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: LyricsService.lineTextAt(popup.currentLyricIndex)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
            font.bold: true
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: LyricsService.lineTextAt(popup.currentLyricIndex + 1)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            color: Theme.textTertiary
        }
    }

    // Symmetric prev(34)/play(46)/next(34) - the Row centers itself in the
    // card, and with matching side-button widths the primary play button
    // lands dead center. Keep this 3-button; a 4th (e.g. stop) unbalances it.
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.spacing.md

        RoundButton {
            glyph: "󰒮" // nf-md-skip_previous
            enabled: MediaService.canGoPrevious
            onClicked: MediaService.previous()
        }
        RoundButton {
            primary: true
            glyph: MediaService.isPlaying ? "󰏤" : "󰐊" // nf-md-pause / nf-md-play
            enabled: MediaService.canTogglePlaying
            onClicked: MediaService.togglePlay()
        }
        RoundButton {
            glyph: "󰒭" // nf-md-skip_next
            enabled: MediaService.canGoNext
            onClicked: MediaService.next()
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs

        Slider {
            width: parent.width
            value: popup.progress
            draggable: MediaService.canSeek
            onMoved: v => MediaService.seek(v * MediaService.length)
        }

        Item {
            width: parent.width
            height: 14

            Text {
                anchors.left: parent.left
                text: MediaService.formatTime(MediaService.position)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: Theme.textTertiary
            }

            Text {
                anchors.right: parent.right
                text: MediaService.formatTime(MediaService.length)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: Theme.textTertiary
            }
        }
    }
}
