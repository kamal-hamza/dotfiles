import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../theme"

// Volume pill, mirroring the waybar pulseaudio module: shows the
// default sink's volume, scroll to adjust it, click to open the full
// mixer. Reactive to Pipewire state, so it also follows changes made
// elsewhere (media keys, pavucontrol, etc).
Rectangle {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Keeps the sink's audio properties bound and updating - Pipewire
    // nodes are otherwise inert until something expresses interest.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    implicitWidth: label.implicitWidth + 24
    implicitHeight: Theme.workspaceSize
    radius: height / 2
    color: mouseArea.containsMouse ? Theme.surface : "transparent"
    border.width: 1
    border.color: mouseArea.containsMouse ? Theme.accent : Theme.outline

    Behavior on color {
        ColorAnimation { duration: Theme.animationMs }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animationMs }
    }

    Process {
        id: mixerProcess
        command: ["pavucontrol"]
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
        color: root.muted ? Theme.outline : Theme.text
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: mixerProcess.startDetached()
        onWheel: wheel => {
            if (!root.sink?.audio)
                return;

            const step = 0.05;
            root.sink.audio.volume = wheel.angleDelta.y > 0
                ? Math.min(1, root.volume + step)
                : Math.max(0, root.volume - step);
        }
    }
}
