import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "../../theme"

// Transient bottom-center on-screen display for volume/mute changes -
// reuses the same Pipewire bindings Volume.qml already has, no extra
// polling. Instantiated once per screen (Variants in shell.qml, matching
// Bar.qml), but only shows on whichever screen is currently focused.
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

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: osd.sink?.audio?.volume ?? 0
    readonly property bool muted: osd.sink?.audio?.muted ?? false

    PwObjectTracker {
        objects: osd.sink ? [osd.sink] : []
    }

    property bool shown: false
    property real _lastVolume: -1
    property bool _lastMuted: false
    property bool _baselineSet: false

    function _seedBaseline() {
        osd._lastVolume = osd.volume;
        osd._lastMuted = osd.muted;
        osd._baselineSet = true;
    }

    function _show() {
        if (!osd.isFocusedScreen) return;
        osd.shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: osd.shown = false
    }

    // 1s grace period before watching for deltas, so the very first
    // Pipewire property read on launch doesn't register as a "change" and
    // fire a phantom OSD.
    Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: osd._seedBaseline()
    }

    // Re-seed when the default sink changes, so comparing two different
    // sinks' volumes (e.g. right after switching output in AudioPopup)
    // doesn't register as a phantom change either.
    onSinkChanged: osd._baselineSet = false

    Connections {
        target: osd.sink && osd.sink.audio ? osd.sink.audio : null
        enabled: target !== null
        function onVolumeChanged() {
            if (!osd._baselineSet) { osd._seedBaseline(); return; }
            const v = osd.sink.audio.volume;
            if (Math.abs(v - osd._lastVolume) > 0.001) {
                osd._lastVolume = v;
                osd._show();
            }
        }
        function onMutedChanged() {
            if (!osd._baselineSet) { osd._seedBaseline(); return; }
            const m = osd.sink.audio.muted;
            if (m !== osd._lastMuted) {
                osd._lastMuted = m;
                osd._show();
            }
        }
    }

    implicitWidth: 200
    implicitHeight: 64

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 200
        height: 56
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

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacing.xs

                Text {
                    text: osd.muted ? "󰖁" : "󰕾"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.md
                }
                Text {
                    text: osd.muted ? "Muted" : Math.round(osd.volume * 100) + "%"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.md
                    font.bold: true
                }
            }

            Rectangle {
                width: parent.width
                height: 4
                radius: 2
                color: Theme.border

                Rectangle {
                    width: parent.width * (osd.muted ? 0 : osd.volume)
                    height: parent.height
                    radius: 2
                    color: Theme.emphasis

                    Behavior on width { NumberAnimation { duration: Theme.motion.fast } }
                }
            }
        }
    }
}
