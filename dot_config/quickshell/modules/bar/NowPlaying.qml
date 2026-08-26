import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

// Now-playing pill for MPD only (mpc/ncmpcpp) - deliberately not MPRIS,
// since that would also surface browser tabs and other apps. Polls
// `mpc status` like waybar's custom/media script did, and only shows a
// title while MPD is actively playing (not paused/stopped). Click opens
// NowPlayingPopup for full details and transport controls.
Rectangle {
    id: root

    property bool open: false
    property string label: "Nothing playing"
    property bool active: false

    readonly property int maxTextWidth: 220

    implicitWidth: Math.min(label_.implicitWidth, maxTextWidth) + 24
    implicitHeight: Theme.workspaceSize
    radius: height / 2
    color: mouseArea.containsMouse || root.open ? Theme.surface : "transparent"
    border.width: 1
    border.color: mouseArea.containsMouse || root.open ? Theme.accent : Theme.outline

    Behavior on color {
        ColorAnimation { duration: Theme.animationMs }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.animationMs }
    }

    function applyStatus(output) {
        const lines = output.split("\n");
        const isPlaying = lines.length > 1 && lines[1].includes("[playing]");

        if (!isPlaying || lines[0].trim() === "") {
            root.active = false;
            root.label = "Nothing playing";
            return;
        }

        let title = lines[0];
        const dashIndex = title.lastIndexOf(" - ");
        if (dashIndex !== -1)
            title = title.slice(dashIndex + 3);
        title = title.replace(/\s*\(From.*$/i, "").trim();

        root.active = true;
        root.label = title.length > 0 ? title : "Untitled";
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

    Process {
        id: statusProcess
        command: ["mpc", "status"]
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(text)
        }
    }

    Text {
        id: label_
        anchors.centerIn: parent
        width: Math.min(implicitWidth, root.maxTextWidth)
        elide: Text.ElideRight
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
        font.italic: !root.active
        color: root.active ? Theme.text : Theme.outline
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.open = !root.open
    }
}
