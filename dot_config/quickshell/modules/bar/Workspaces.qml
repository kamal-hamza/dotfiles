import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"

// Fixed-size Hyprland workspace switcher/indicator for a single output.
//
// Reflects live state from Quickshell's Hyprland IPC connection, which
// listens on Hyprland's event socket - so this stays in sync whether a
// workspace change comes from clicking here or from a keybind in
// hyprland.conf. No polling involved.
Row {
    id: root

    required property ShellScreen screen

    // Hyprland workspaces are unbounded, but a fixed strip of buttons
    // reads better than a list that reflows as workspaces come and go.
    property int workspaceCount: 5

    readonly property var monitor: Hyprland.monitorFor(root.screen)
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? -1

    spacing: Theme.workspaceSpacing

    Repeater {
        model: root.workspaceCount

        delegate: Rectangle {
            id: button

            required property int index
            readonly property int wsId: index + 1
            readonly property bool isActive: wsId === root.activeWorkspaceId
            readonly property bool isOccupied: Hyprland.workspaces.values.some(ws => ws.id === wsId)

            width: Theme.workspaceSize
            height: Theme.workspaceSize
            radius: Theme.workspaceRadius
            color: isActive ? Theme.accent : isOccupied ? Theme.surface : "transparent"
            border.width: isActive ? 0 : 1
            border.color: Theme.outline

            Behavior on color {
                ColorAnimation { duration: Theme.animationMs }
            }

            Text {
                anchors.centerIn: parent
                text: button.wsId
                font.pixelSize: 13
                font.bold: button.isActive
                color: button.isActive ? Theme.textOnAccent : Theme.text
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Hyprland's classic IPC takes a plain "workspace N"
                    // request, but a Lua-configured instance (hyprland.lua
                    // here) routes dispatch through its Lua VM instead,
                    // which needs an actual hl.dsp.* dispatcher call.
                    const request = Hyprland.usingLua
                        ? "hl.dsp.focus({workspace=" + button.wsId + "})"
                        : "workspace " + button.wsId;
                    Hyprland.dispatch(request);
                }
            }
        }
    }
}
