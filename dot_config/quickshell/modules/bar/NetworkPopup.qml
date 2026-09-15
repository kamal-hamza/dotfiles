import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import "../../theme"
import "../common"

// Body shown from the network pill: connection state, current network +
// signal, IP address, and the visible wifi list (connect to known networks
// only - no PSK-entry dialog this pass).
PopupCard {
    id: popup

    cardWidth: 300

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
        const dev = popup._wifiDevice;
        if (!dev || !dev.networks) return null;
        const nets = dev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected) return nets[i];
        }
        return null;
    }
    readonly property bool wiredConnected: popup._wiredDevice !== null
        && popup._wiredDevice.hasLink && popup._wiredDevice.connected

    readonly property var _networks: {
        const dev = popup._wifiDevice;
        if (!dev || !dev.networks) return [];
        const all = dev.networks.values;
        const out = [];
        for (let i = 0; i < all.length; i++) {
            const n = all[i];
            if (n && n.name && n.name.length > 0) out.push(n);
        }
        out.sort((a, b) => a.connected !== b.connected
            ? (a.connected ? -1 : 1)
            : b.signalStrength - a.signalStrength);
        return out;
    }

    property string ipInfo: ""

    function securityLabel(sec) {
        switch (sec) {
        case WifiSecurityType.Open: return "";
        case WifiSecurityType.Owe: return "OWE";
        case WifiSecurityType.WpaPsk: return "WPA";
        case WifiSecurityType.Wpa2Psk: return "WPA2";
        case WifiSecurityType.Sae: return "WPA3";
        case WifiSecurityType.Wpa3SuiteB192: return "WPA3";
        case WifiSecurityType.WpaEap: return "WPA-EAP";
        case WifiSecurityType.Wpa2Eap: return "WPA2-EAP";
        case WifiSecurityType.StaticWep:
        case WifiSecurityType.DynamicWep: return "WEP";
        case WifiSecurityType.Leap: return "LEAP";
        default: return "";
        }
    }

    // NetworkDevice.address is the MAC, not an IP - there's no native IP
    // lookup, so this is a one-shot call made only when the popup opens,
    // not a poll.
    onVisibleChanged: {
        if (!popup.visible) return;
        popup.ipInfo = "";
        const dev = popup.wiredConnected ? popup._wiredDevice : popup._wifiDevice;
        if (dev) {
            ipProcess.command = ["sh", "-c", "ip -4 -o addr show " + dev.name + " | awk '{print $4}' | cut -d/ -f1"];
            ipProcess.running = true;
        }
    }

    Process {
        id: ipProcess
        stdout: StdioCollector {
            onStreamFinished: popup.ipInfo = text.trim()
        }
    }

    Column {
        width: parent.width
        spacing: 2

        Text {
            text: popup.wiredConnected ? "Wired connection"
                : (popup._activeWifiNetwork ? popup._activeWifiNetwork.name : "Not connected")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            font.bold: true
        }

        Text {
            visible: popup.ipInfo.length > 0
            text: popup.ipInfo
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Text {
            visible: popup._activeWifiNetwork !== null && !popup.wiredConnected
            text: popup._activeWifiNetwork
                ? Math.round(popup._activeWifiNetwork.signalStrength * 100) + "% signal"
                : ""
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: popup._networks.length > 0

        Text {
            text: "Networks"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            bottomPadding: 2
        }

        Repeater {
            model: ScriptModel { values: popup._networks }

            delegate: Rectangle {
                id: netRow
                required property var modelData

                width: parent ? parent.width : 260
                height: 32
                radius: Theme.radius.control
                color: netMa.containsMouse ? Theme.bgHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.spacing.sm
                    spacing: Theme.spacing.xs

                    Text {
                        width: parent.width - secText.implicitWidth - sigText.implicitWidth - parent.spacing * 2
                        text: netRow.modelData.name
                        color: netRow.modelData.connected ? Theme.textStrong : Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        font.bold: netRow.modelData.connected
                        elide: Text.ElideRight
                    }
                    Text {
                        id: secText
                        text: popup.securityLabel(netRow.modelData.security)
                        color: Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                    }
                    Text {
                        id: sigText
                        text: Math.round(netRow.modelData.signalStrength * 100) + "%"
                        color: Theme.textTertiary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                    }
                }

                MouseArea {
                    id: netMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!netRow.modelData.connected) netRow.modelData.connect();
                    }
                }
            }
        }
    }

    Text {
        visible: popup._networks.length === 0 && !popup.wiredConnected
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "No networks found"
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
    }
}
