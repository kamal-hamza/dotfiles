import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import "../../theme"

// Shared Lock/Logout/Suspend/Reboot/Shutdown action list, used by both the
// bar's anchored PowerMenu popup and the launcher's centered PowerMode.
// Destructive actions (reboot/shutdown) require a second click within 3s -
// an inline "Confirm?" state that replaces the row's label entirely, rather
// than a second panel or a color-only change.
Column {
    id: root

    property int rowHeight: 36
    property real glyphSize: Theme.font.md
    property real labelSize: Theme.font.sm
    // -1 = no keyboard selection yet (the bar's mouse-only anchored popup
    // never sets this, so it keeps its original hover-only look; PowerMode
    // sets it to 0 on open since it's keyboard-first).
    property int selectedIndex: -1
    spacing: 2

    function selectNext() { root.selectedIndex = Math.min(root.selectedIndex + 1, actionRepeater.length - 1); }
    function selectPrevious() { root.selectedIndex = Math.max(root.selectedIndex - 1, 0); }
    function activateSelected() {
        const row = actionRepeater[root.selectedIndex];
        if (row) row.trigger();
    }

    component ActionRow: Rectangle {
        id: row
        property int index: -1
        property string glyph: ""
        property string label: ""
        property bool destructive: false
        property bool confirming: false
        readonly property bool selected: root.selectedIndex === index
        signal activate()

        function trigger() {
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

        width: parent ? parent.width : 176
        height: root.rowHeight
        radius: Theme.radius.control
        color: (rowMa.containsMouse || row.selected) ? Theme.bgHover : "transparent"
        border.width: row.selected ? 1 : 0
        border.color: Theme.borderMid

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Timer {
            id: confirmTimeout
            interval: 3000
            onTriggered: row.confirming = false
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.sm
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.sm
            spacing: 0

            Row {
                spacing: Theme.spacing.sm
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.glyph
                    font.family: Theme.fontFamily
                    font.pixelSize: root.glyphSize
                    color: row.confirming ? Theme.emphasis : Theme.textPrimary
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.confirming ? (row.label + "?") : row.label
                    font.family: Theme.fontFamily
                    font.pixelSize: root.labelSize
                    font.bold: row.confirming
                    color: row.confirming ? Theme.emphasis : Theme.textPrimary
                }
            }
            Text {
                visible: row.confirming
                text: "Press again to confirm · Esc to cancel"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: Theme.textTertiary
            }
        }

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: root.selectedIndex = row.index
            onClicked: row.trigger()
        }
    }

    // Cancels any pending destructive confirmation - callers wire this to
    // their own Escape handling so a stray Esc cancels the confirm state
    // before it closes the surrounding popup/window.
    function cancelConfirm() {
        for (let i = 0; i < actionRepeater.length; i++) actionRepeater[i].confirming = false;
    }

    readonly property var actionRepeater: [lockRow, logoutRow, suspendRow, rebootRow, shutdownRow]
    readonly property bool anyConfirming: rebootRow.confirming || shutdownRow.confirming

    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: suspendProc; command: ["systemctl", "suspend"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }

    ActionRow {
        id: lockRow
        index: 0
        glyph: "󰌾" // nf-md-lock
        label: "Lock"
        onActivate: lockProc.running = true
    }
    ActionRow {
        id: logoutRow
        index: 1
        glyph: "󰍃" // nf-md-logout
        label: "Logout"
        onActivate: {
            // Hyprland's classic IPC takes a plain "exit" dispatch, but a
            // Lua-configured instance (hyprland.lua here) routes dispatch
            // through its Lua VM instead - same branching Workspaces.qml
            // uses for workspace switches.
            const request = Hyprland.usingLua ? "hl.dsp.exit()" : "exit";
            Hyprland.dispatch(request);
        }
    }
    ActionRow {
        id: suspendRow
        index: 2
        glyph: "󰤄" // nf-md-sleep
        label: "Suspend"
        onActivate: suspendProc.running = true
    }
    ActionRow {
        id: rebootRow
        index: 3
        glyph: "󰜉" // nf-md-restart
        label: "Reboot"
        destructive: true
        onActivate: rebootProc.running = true
    }
    ActionRow {
        id: shutdownRow
        index: 4
        glyph: "󰐥" // nf-md-power
        label: "Shutdown"
        destructive: true
        onActivate: shutdownProc.running = true
    }
}
