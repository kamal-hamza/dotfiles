import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../theme"

// Floating toast stack - the actual replacement for what mako renders.
// Instantiated once per screen (via Variants in shell.qml, same pattern
// Bar.qml uses), but only renders notifications pinned to whichever screen
// was focused when they arrived, so a multi-monitor setup doesn't pop the
// same toast on every output at once.
PanelWindow {
    id: toastHost

    required property var modelData

    screen: toastHost.modelData
    color: "transparent"
    focusable: false
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 12
    }

    readonly property bool isFocusedScreen: Hyprland.focusedMonitor && toastHost.screen
        ? Hyprland.focusedMonitor.name === toastHost.screen.name
        : false

    readonly property var _visibleNotifs: {
        if (!toastHost.isFocusedScreen) return [];
        const all = NotificationService.trackedNotifications
            ? NotificationService.trackedNotifications.values : [];
        const ids = NotificationService.popupIds;
        const out = [];
        for (let i = 0; i < ids.length; i++) {
            const n = all.find(x => x && x.id === ids[i]);
            if (n) out.push(n);
        }
        return out;
    }

    implicitWidth: 320
    implicitHeight: stack.implicitHeight

    Column {
        id: stack
        width: 320
        spacing: Theme.spacing.sm

        Repeater {
            model: ScriptModel { values: toastHost._visibleNotifs }
            delegate: NotificationCard {
                required property var modelData
                width: parent ? parent.width : 320
                notif: modelData
                mode: "popup"
            }
        }
    }
}
