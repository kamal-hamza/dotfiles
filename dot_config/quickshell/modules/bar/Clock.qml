import QtQuick
import Quickshell
import "../../theme"

// Minimal clock pill: shows HH:MM, ticking once a minute. Click toggles
// the CalendarPopup dropdown (owned by Bar.qml, which reads `open`).
Rectangle {
    id: root

    property bool open: false

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")

    implicitWidth: label.implicitWidth + 24
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

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.time
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: true
        color: Theme.text
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.open = !root.open
    }
}
