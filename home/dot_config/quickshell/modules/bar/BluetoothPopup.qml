import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../../theme"
import "../common"

// Body shown from the bluetooth pill: adapter power/scan controls, and
// devices grouped into Connected / Paired / Available. Left-click does the
// state-appropriate action (pair -> connect -> disconnect); right-click
// forgets a paired device. Connected devices show battery when available.
PopupCard {
    id: popup

    cardWidth: 300

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool adapterEnabled: popup.adapter !== null && popup.adapter.enabled
    readonly property bool scanning: popup.adapter !== null && popup.adapter.discovering

    readonly property var _grouped: {
        const all = Bluetooth.devices ? Bluetooth.devices.values : [];
        const connected = [];
        const paired = [];
        const available = [];
        for (let i = 0; i < all.length; i++) {
            const d = all[i];
            if (!d) continue;
            if (d.connected) connected.push(d);
            else if (d.paired || d.bonded) paired.push(d);
            else available.push(d);
        }
        const byName = (a, b) => (a.name || a.deviceName || "").localeCompare(b.name || b.deviceName || "");
        connected.sort(byName);
        paired.sort(byName);
        available.sort(byName);
        return { connected, paired, available };
    }

    component DeviceRow: Rectangle {
        id: row
        required property var device

        width: parent ? parent.width : 260
        height: 36
        radius: Theme.radius.control
        color: rowMa.containsMouse ? Theme.bgHover : "transparent"

        readonly property string label: row.device ? (row.device.name || row.device.deviceName || "Unknown") : ""
        readonly property bool isConnected: row.device && row.device.connected
        readonly property bool isPaired: row.device && (row.device.paired || row.device.bonded)
        readonly property bool isPairing: row.device && row.device.pairing
        readonly property bool hasBattery: row.device && row.device.batteryAvailable

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        function statusText() {
            if (row.isPairing) return "pairing…";
            if (row.isConnected) return "connected";
            if (row.isPaired) return "paired";
            return "available";
        }

        function primaryAction() {
            if (!row.device) return;
            if (row.isPairing) { row.device.cancelPair(); return; }
            if (row.isConnected) { row.device.disconnect(); return; }
            if (row.isPaired) { row.device.connect(); return; }
            row.device.pair();
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.sm
            spacing: Theme.spacing.xs

            Column {
                width: parent.width - (row.hasBattery ? batteryText.implicitWidth + parent.spacing : 0)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    text: row.label
                    color: row.isConnected ? Theme.textStrong : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    font.bold: row.isConnected
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: row.statusText()
                    color: Theme.textTertiary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
            }

            Text {
                id: batteryText
                anchors.verticalCenter: parent.verticalCenter
                visible: row.hasBattery
                // battery is fractional (0.0-1.0), not a percentage.
                text: row.hasBattery ? Math.round(row.device.battery * 100) + "%" : ""
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) row.primaryAction();
                else if (mouse.button === Qt.RightButton && row.isPaired) row.device.forget();
            }
        }
    }

    component SectionLabel: Text {
        property string label: ""
        property int count: 0
        text: count > 0 ? label + "  ·  " + count : label
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.xs
        bottomPadding: 2
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        Text {
            width: parent.width - scanBtn.width - powerSwitch.width - parent.spacing * 2
            anchors.verticalCenter: parent.verticalCenter
            text: popup.adapter ? (popup.adapterEnabled ? popup.adapter.name : "Off") : "No adapter"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            id: scanBtn
            anchors.verticalCenter: parent.verticalCenter
            text: "󰑐" // nf-md-refresh
            color: popup.scanning ? Theme.textStrong : Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
            opacity: popup.adapterEnabled ? 1 : 0.35

            RotationAnimation on rotation {
                running: popup.scanning
                from: 0
                to: 360
                duration: 1200
                loops: Animation.Infinite
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                enabled: popup.adapterEnabled
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (popup.adapter) popup.adapter.discovering = !popup.adapter.discovering;
                }
            }
        }

        Rectangle {
            id: powerSwitch
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 18
            radius: 9
            color: popup.adapterEnabled ? Theme.emphasis : Theme.bgControl
            border.width: 1
            border.color: Theme.border

            Behavior on color { ColorAnimation { duration: Theme.motion.base } }

            Rectangle {
                width: 14
                height: 14
                radius: 7
                anchors.verticalCenter: parent.verticalCenter
                x: popup.adapterEnabled ? parent.width - width - 2 : 2
                color: popup.adapterEnabled ? Theme.textOnEmphasis : Theme.textSecondary

                Behavior on x { NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (popup.adapter) popup.adapter.enabled = !popup.adapter.enabled;
                }
            }
        }
    }

    Text {
        visible: !popup.adapterEnabled
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: popup.adapter ? "Bluetooth is off" : "No bluetooth adapter found"
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
        topPadding: Theme.spacing.sm
        bottomPadding: Theme.spacing.sm
    }

    Column {
        width: parent.width
        spacing: 2
        visible: popup.adapterEnabled && popup._grouped.connected.length > 0

        SectionLabel { label: "Connected"; count: popup._grouped.connected.length }
        Repeater {
            model: ScriptModel { values: popup._grouped.connected }
            delegate: DeviceRow {
                required property var modelData
                device: modelData
            }
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: popup.adapterEnabled && popup._grouped.paired.length > 0

        SectionLabel { label: "Paired"; count: popup._grouped.paired.length }
        Repeater {
            model: ScriptModel { values: popup._grouped.paired }
            delegate: DeviceRow {
                required property var modelData
                device: modelData
            }
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: popup.adapterEnabled && popup._grouped.available.length > 0

        SectionLabel { label: "Available"; count: popup._grouped.available.length }
        Repeater {
            model: ScriptModel { values: popup._grouped.available }
            delegate: DeviceRow {
                required property var modelData
                device: modelData
            }
        }
    }
}
