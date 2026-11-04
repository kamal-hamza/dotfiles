import QtQuick
import "../../theme"
import "../common"
import "../services"

// Next-prayer pill: only the upcoming prayer + its time. Click toggles
// PrayerPopup (the full day + location/method settings), owned by Bar.qml.
Pill {
    id: root

    property bool open: false

    active: root.open

    Text {
        text: PrayerService.next
            ? PrayerService.next.label + " " + PrayerService.formatTime(PrayerService.next.time)
            : (PrayerService.locating ? "Locating…" : "Prayer")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
        color: Theme.textPrimary
    }

    onClicked: root.open = !root.open
}
