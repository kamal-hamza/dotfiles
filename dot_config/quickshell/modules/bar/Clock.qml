import QtQuick
import Quickshell
import "../../theme"
import "../common"

// Clock pill: shows HH:MM, ticking once a minute. Click toggles the
// CalendarPopup dropdown (owned by Bar.qml, which reads `open`).
Pill {
    id: root

    property bool open: false

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")

    active: root.open

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: root.time
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        font.bold: true
        color: Theme.textPrimary
    }

    onClicked: root.open = !root.open
}
