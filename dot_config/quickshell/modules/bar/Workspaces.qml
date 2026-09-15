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

            width: Theme.workspaceSize
            height: Theme.workspaceSize
            radius: Theme.workspaceRadius
            scale: isActive ? 1 : (mouseArea.containsMouse ? 1.08 : 1)
            // Only the active workspace gets a fill; occupied-but-inactive
            // workspaces stay the same as empty ones (no grey).
            color: isActive ? Theme.emphasis : (mouseArea.containsMouse ? Theme.bgHover : "transparent")
            border.width: isActive ? 0 : 1
            border.color: mouseArea.containsMouse ? Theme.borderHover : Theme.border

            Behavior on color {
                ColorAnimation { duration: Theme.motion.fast }
            }
            Behavior on border.color {
                ColorAnimation { duration: Theme.motion.fast }
            }
            Behavior on scale {
                NumberAnimation { duration: Theme.motion.fast; easing.type: Theme.motion.curve }
            }

            Text {
                anchors.centerIn: parent
                text: button.wsId
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                font.bold: button.isActive
                color: button.isActive ? Theme.textOnEmphasis : Theme.textPrimary
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
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
