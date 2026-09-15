import QtQuick
import "../../theme"
import "../common"

// Icon-only pill at the far right edge. Click opens PowerMenu.
Pill {
    id: root

    property bool open: false

    active: root.open

    Text {
        text: "󰐥" // nf-md-power
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: Theme.textPrimary
    }

    onClicked: root.open = !root.open
}
