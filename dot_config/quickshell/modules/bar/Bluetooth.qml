import QtQuick
import Quickshell.Bluetooth
import "../../theme"
import "../common"

// Bluetooth pill, native Quickshell.Bluetooth. Click opens BluetoothPopup
// for the device list.
Pill {
    id: root

    property bool open: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: root.adapter !== null && root.adapter.enabled
    readonly property int connectedCount: {
        const all = Bluetooth.devices ? Bluetooth.devices.values : [];
        let n = 0;
        for (let i = 0; i < all.length; i++) {
            if (all[i] && all[i].connected) n++;
        }
        return n;
    }

    active: root.open

    Text {
        text: !root.enabled ? "󰂲" // nf-md-bluetooth_off
            : (root.connectedCount > 0 ? "󰂱  " + root.connectedCount : "󰂯") // connected / idle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: root.enabled ? Theme.textPrimary : Theme.textTertiary
    }

    onClicked: root.open = !root.open
}
