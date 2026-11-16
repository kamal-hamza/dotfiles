import QtQuick
import Quickshell.Networking
import "../../theme"
import "../common"

// Network pill, native Quickshell.Networking - reactive, no nmcli
// shell-outs/polling. Click opens NetworkPopup for the network list.
Pill {
    id: root

    property bool open: false

    readonly property var _wifiDevice: {
        const all = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < all.length; i++) {
            if (all[i] && all[i].type === DeviceType.Wifi) return all[i];
        }
        return null;
    }
    readonly property var _wiredDevice: {
        const all = Networking.devices ? Networking.devices.values : [];
        for (let i = 0; i < all.length; i++) {
            if (all[i] && all[i].type === DeviceType.Wired) return all[i];
        }
        return null;
    }
    readonly property var _activeWifiNetwork: {
        const dev = root._wifiDevice;
        if (!dev || !dev.networks) return null;
        const nets = dev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected) return nets[i];
        }
        return null;
    }

    readonly property bool wiredConnected: root._wiredDevice !== null
        && root._wiredDevice.hasLink && root._wiredDevice.connected
    readonly property bool wifiConnected: root._activeWifiNetwork !== null
    // signalStrength is 0.0-1.0, not a percentage.
    readonly property int signalPercent: root._activeWifiNetwork
        ? Math.round(root._activeWifiNetwork.signalStrength * 100) : 0

    readonly property string glyph: {
        if (root.wiredConnected) return "󰈀"; // nf-md-ethernet
        if (root.wifiConnected) {
            if (root.signalPercent >= 80) return "󰤨";
            if (root.signalPercent >= 60) return "󰤥";
            if (root.signalPercent >= 40) return "󰤢";
            if (root.signalPercent >= 20) return "󰤟";
            return "󰤯";
        }
        return "󰤭"; // nf-md-wifi_off
    }

    active: root.open

    // scannerEnabled is a continuous mode, not a one-shot rescan trigger -
    // without it, `networks` collapses to a single entry instead of the
    // visible APs. Kept enabled declaratively rather than wired through a
    // signal handler, so it re-applies whenever the device object itself
    // changes (e.g. the adapter coming back after being toggled off).
    Binding {
        target: root._wifiDevice
        property: "scannerEnabled"
        value: true
        when: root._wifiDevice !== null && Networking.wifiEnabled
    }

    Text {
        text: root.glyph + (root.wifiConnected && !root.wiredConnected ? "  " + root.signalPercent + "%" : "")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: (root.wiredConnected || root.wifiConnected) ? Theme.textPrimary : Theme.textTertiary
    }

    onClicked: root.open = !root.open
}
