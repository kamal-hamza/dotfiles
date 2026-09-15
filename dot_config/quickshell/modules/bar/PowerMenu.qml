import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../../theme"
import "../common"

// Body shown from the power button: Lock / Logout / Suspend / Reboot /
// Shutdown. Destructive actions (reboot/shutdown) require a second click
// within 3s - an inline "Confirm?" state rather than a second panel.
PopupCard {
    id: popup

    cardWidth: 200

    component ActionRow: Rectangle {
        id: row
        property string glyph: ""
        property string label: ""
        property bool destructive: false
        property bool confirming: false
        signal activate()

        width: parent ? parent.width : 176
        height: 36
        radius: Theme.radius.control
        color: rowMa.containsMouse ? Theme.bgHover : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Timer {
            id: confirmTimeout
            interval: 3000
            onTriggered: row.confirming = false
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.sm
            spacing: Theme.spacing.sm

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: row.glyph
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                color: row.confirming ? Theme.emphasis : Theme.textPrimary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: row.confirming ? "Confirm?" : row.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.sm
                font.bold: row.confirming
                color: row.confirming ? Theme.emphasis : Theme.textPrimary
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!row.destructive) {
                    row.activate();
                    return;
                }
                if (row.confirming) {
                    confirmTimeout.stop();
                    row.confirming = false;
                    row.activate();
                } else {
                    row.confirming = true;
                    confirmTimeout.restart();
                }
            }
        }
    }

    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: suspendProc; command: ["systemctl", "suspend"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }

    Column {
        width: parent.width
        spacing: 2

        ActionRow {
            glyph: "󰌾" // nf-md-lock
            label: "Lock"
            onActivate: lockProc.running = true
        }
        ActionRow {
            glyph: "󰍃" // nf-md-logout
            label: "Logout"
            onActivate: {
                // Hyprland's classic IPC takes a plain "exit" dispatch, but
                // a Lua-configured instance (hyprland.lua here) routes
                // dispatch through its Lua VM instead - same branching
                // Workspaces.qml uses for workspace switches.
                const request = Hyprland.usingLua ? "hl.dsp.exit()" : "exit";
                Hyprland.dispatch(request);
            }
        }
        ActionRow {
            glyph: "󰤄" // nf-md-sleep
            label: "Suspend"
            onActivate: suspendProc.running = true
        }
        ActionRow {
            glyph: "󰜉" // nf-md-restart
            label: "Reboot"
            destructive: true
            onActivate: rebootProc.running = true
        }
        ActionRow {
            glyph: "󰐥" // nf-md-power
            label: "Shutdown"
            destructive: true
            onActivate: shutdownProc.running = true
        }
    }
}
