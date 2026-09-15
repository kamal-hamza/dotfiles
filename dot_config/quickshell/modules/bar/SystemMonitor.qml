import QtQuick
import "../../theme"
import "../common"
import "../services"

// Compact CPU/RAM readout, driven by SystemMonitorService's always-on light
// sampling tier. Click opens SystemMonitorPopup for GPU/disk/network/
// top-process detail (sampled only while that popup is open).
Pill {
    id: root

    property bool open: false

    active: root.open

    Row {
        spacing: Theme.spacing.sm

        Row {
            spacing: 4
            Text {
                text: "󰘚"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                color: Theme.textTertiary
            }
            Text {
                text: Math.round(SystemMonitorService.cpuPercent) + "%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.sm
                color: Theme.textPrimary
            }
        }

        Row {
            spacing: 4
            Text {
                text: "󰍛"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                color: Theme.textTertiary
            }
            Text {
                text: Math.round(SystemMonitorService.ramPercent) + "%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.sm
                color: Theme.textPrimary
            }
        }
    }

    onClicked: root.open = !root.open
}
