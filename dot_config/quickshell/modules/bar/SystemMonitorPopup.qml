import QtQuick
import Quickshell
import "../../theme"
import "../common"
import "../services"

// Body shown from the SystemMonitor pill: CPU/RAM (already sampling for
// the pill) plus disk/network/GPU/top-processes, sampled only while this
// body is active - the "on-demand" half of the Activity Monitor brief.
PopupCard {
    id: popup

    cardWidth: 320

    onVisibleChanged: {
        if (popup.visible) SystemMonitorService.startDetail();
        else SystemMonitorService.stopDetail();
    }

    component MeterRow: Column {
        id: meterRow

        required property string label
        required property string valueText
        required property real fraction

        width: parent ? parent.width : 280
        spacing: 4

        Row {
            width: meterRow.width
            Text {
                width: parent.width - valueLabel.implicitWidth
                text: meterRow.label
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }
            Text {
                id: valueLabel
                text: meterRow.valueText
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: true
            }
        }

        Slider {
            width: meterRow.width
            draggable: false
            value: meterRow.fraction
        }
    }

    MeterRow {
        label: "CPU"
        valueText: Math.round(SystemMonitorService.cpuPercent) + "%"
            + (SystemMonitorService.cpuTempAvailable ? "  ·  " + Math.round(SystemMonitorService.cpuTempC) + "°C" : "")
        fraction: SystemMonitorService.cpuPercent / 100
    }

    MeterRow {
        label: "Memory"
        valueText: SystemMonitorService.formatMb(SystemMonitorService.ramUsedMb) + " / " + SystemMonitorService.formatMb(SystemMonitorService.ramTotalMb)
        fraction: SystemMonitorService.ramPercent / 100
    }

    MeterRow {
        label: "Disk (/)"
        valueText: SystemMonitorService.diskUsedGb.toFixed(0) + " GB / " + SystemMonitorService.diskTotalGb.toFixed(0) + " GB"
        fraction: SystemMonitorService.diskPercent / 100
    }

    MeterRow {
        visible: SystemMonitorService.gpuAvailable
        label: "GPU" + (SystemMonitorService.gpuTempC > 0 ? "  ·  " + Math.round(SystemMonitorService.gpuTempC) + "°C" : "")
        valueText: Math.round(SystemMonitorService.gpuPercent) + "%  ·  " + SystemMonitorService.formatMb(SystemMonitorService.vramUsedMb) + " VRAM"
        fraction: SystemMonitorService.gpuPercent / 100
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.md

        Text {
            text: "↓ " + SystemMonitorService.formatKBs(SystemMonitorService.netRxKBs)
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
        Text {
            text: "↑ " + SystemMonitorService.formatKBs(SystemMonitorService.netTxKBs)
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: SystemMonitorService.topProcesses.length > 0

        Text {
            text: "Top processes"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            bottomPadding: 2
        }

        Repeater {
            model: ScriptModel { values: SystemMonitorService.topProcesses }

            delegate: Row {
                id: procRow
                required property var modelData

                width: parent ? parent.width : 280
                height: 20

                Text {
                    width: parent.width - cpuText.implicitWidth - memText.implicitWidth - Theme.spacing.xs * 2
                    anchors.verticalCenter: parent.verticalCenter
                    text: procRow.modelData.name
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    elide: Text.ElideRight
                }
                Text {
                    id: cpuText
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: procRow.modelData.cpu.toFixed(1) + "%"
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
                Text {
                    id: memText
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    text: procRow.modelData.mem.toFixed(1) + "%"
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
            }
        }
    }
}
