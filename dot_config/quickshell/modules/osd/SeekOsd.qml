import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"
import "../services"

// Transient bottom-center on-screen display for song-seek changes (Super+
// Shift+,/Super+Shift+. - see keymaps.lua), styled to match VolumeOsd.qml.
// Unlike VolumeOsd, this can't just watch a property change reactively -
// MPRIS position isn't pushed on external seeks (see MediaService's
// tickProgress comment) - so it's shown explicitly via MediaOsdService's
// trigger, bumped over `qs ipc call mediaOsd seek` right after the keybind's
// `mpc seek`. Instantiated once per screen (Variants in shell.qml, matching
// Bar.qml/VolumeOsd.qml), but only shows on whichever screen is currently
// focused.
PanelWindow {
    id: osd

    required property var modelData

    screen: osd.modelData
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Ignore

    anchors {
        bottom: true
    }
    margins {
        bottom: 28
    }

    readonly property bool isFocusedScreen: Hyprland.focusedMonitor && osd.screen
        ? Hyprland.focusedMonitor.name === osd.screen.name
        : false

    readonly property real progress: MediaService.length > 0
        ? Math.max(0, Math.min(1, MediaService.position / MediaService.length)) : 0

    property bool shown: false

    function _show() {
        if (!osd.isFocusedScreen) return;
        if (!MediaService.hasPlayer) return;
        // Forces a fresh read of position, which mpc's synchronous seek
        // (the caller already awaited it via `&&` before this IPC call
        // fired) should have already propagated through mpd-mpris.
        MediaService.tickProgress();
        osd.shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osd.shown = false
    }

    Connections {
        target: MediaOsdService
        function onTriggerChanged() { osd._show(); }
    }

    implicitWidth: 260
    implicitHeight: 74

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 260
        height: 66
        radius: Theme.radius.card
        color: Theme.bgElevated
        border.width: 1
        border.color: Theme.border

        opacity: osd.shown ? 1 : 0
        scale: osd.shown ? 1 : 0.95

        Behavior on opacity { NumberAnimation { duration: Theme.motion.base } }
        Behavior on scale { NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve } }

        Column {
            anchors.centerIn: parent
            width: parent.width - Theme.spacing.lg * 2
            spacing: Theme.spacing.xs

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: MediaService.trackTitle
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Theme.border

                Rectangle {
                    width: parent.width * osd.progress
                    height: parent.height
                    radius: 2
                    color: Theme.emphasis

                    Behavior on width { NumberAnimation { duration: Theme.motion.fast } }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacing.xs

                Text {
                    text: MediaService.formatTime(MediaService.position)
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
                Text {
                    text: "/"
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
                Text {
                    text: MediaService.formatTime(MediaService.length)
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
            }
        }
    }
}
