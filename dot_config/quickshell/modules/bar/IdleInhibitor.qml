import QtQuick
import Quickshell.Wayland
import "../../theme"
import "../common"

// "Keep awake" toggle using the native wlr-idle-inhibit protocol - no
// daemon, no polling. The inhibitor only holds while its window stays
// mapped, so it's attached to the bar's own always-mapped window rather
// than anything conditionally visible.
Pill {
    id: root

    required property var anchorWindow

    IdleInhibitor {
        enabled: root.active
        window: root.anchorWindow
    }

    Text {
        text: root.active ? "󰅶" : "󰛊" // nf-md-coffee (keep-awake on/off)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: root.active ? Theme.emphasis : Theme.textPrimary
    }

    onClicked: root.active = !root.active
}
