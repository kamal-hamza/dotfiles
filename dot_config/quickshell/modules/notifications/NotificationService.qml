pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications

// The real notification daemon for this desktop - registers
// org.freedesktop.Notifications, superseding mako. History needs no
// storage of its own: trackedNotifications (from the server) already is
// it. What this tracks on top: which tracked ids are currently showing as
// a floating toast (popupIds - auto-expiry just drops an id from here, the
// notification stays in trackedNotifications/the center), which screen each
// one arrived on (for per-monitor toast pinning), and do-not-disturb.
QtObject {
    id: root

    readonly property var trackedNotifications: server.trackedNotifications

    property var popupIds: []
    property bool dndEnabled: false
    property var notificationTimestamps: ({})
    property var notificationScreens: ({})

    // Incremented once a minute so relativeTime() stays live without every
    // card needing its own timer.
    property int tick: 0

    function toggleDnd() {
        root.dndEnabled = !root.dndEnabled;
    }

    function removeFromPopup(id) {
        const next = root.popupIds.filter(x => x !== id);
        if (next.length !== root.popupIds.length)
            root.popupIds = next;
    }

    function clearAll() {
        const list = root.trackedNotifications ? root.trackedNotifications.values.slice() : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i]) list[i].dismiss();
        }
        root.popupIds = [];
    }

    function defaultActionFor(notif) {
        if (!notif || !notif.actions) return null;
        const list = notif.actions;
        for (let i = 0; i < list.length; i++) {
            if (list[i].identifier === "default") return list[i];
        }
        return null;
    }

    // Quickshell wraps some image hints as image://icon/<value> even when
    // the value is actually a filesystem path (observed from screenshot
    // tools). The icon provider can't resolve a path and silently returns a
    // Ready-status placeholder (a checkerboard) instead of failing, so that
    // case has to be unwrapped back to a real file:// URL first.
    function resolveImage(src) {
        if (!src) return "";
        const iconPrefix = "image://icon/";
        if (src.indexOf(iconPrefix) === 0) {
            const inner = src.slice(iconPrefix.length);
            if (inner.indexOf("/") === 0) return "file://" + inner;
            return src;
        }
        if (src.indexOf("data:") === 0) return src;
        if (src.indexOf("/") === 0) return "file://" + src;
        if (src.indexOf("://") >= 0) return src;
        return Quickshell.iconPath(src, true);
    }

    function relativeTime(id) {
        const _tick = root.tick; // reactivity dependency
        const ts = root.notificationTimestamps[id];
        if (!ts) return "";
        const diff = (Date.now() - ts) / 1000;
        if (diff < 60) return "just now";
        if (diff < 3600) return Math.floor(diff / 60) + " min ago";
        if (diff < 86400) return Math.floor(diff / 3600) + " hr ago";
        return Math.floor(diff / 86400) + "d ago";
    }

    property NotificationServer server: NotificationServer {
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true;

            const stamps = Object.assign({}, root.notificationTimestamps);
            stamps[notification.id] = Date.now();
            root.notificationTimestamps = stamps;

            const screens = Object.assign({}, root.notificationScreens);
            screens[notification.id] = Hyprland.focusedMonitor
                ? Hyprland.focusedMonitor.name
                : (Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "");
            root.notificationScreens = screens;

            const isCritical = notification.urgency === NotificationUrgency.Critical;
            if (!root.dndEnabled || isCritical) {
                const ids = root.popupIds.slice();
                ids.push(notification.id);
                root.popupIds = ids;
            }
        }
    }

    property Connections _cleanup: Connections {
        target: root.trackedNotifications
        function onObjectRemovedPost(obj) {
            if (!obj) return;
            root.removeFromPopup(obj.id);

            if (root.notificationTimestamps[obj.id] !== undefined) {
                const stamps = Object.assign({}, root.notificationTimestamps);
                delete stamps[obj.id];
                root.notificationTimestamps = stamps;
            }
            if (root.notificationScreens[obj.id] !== undefined) {
                const screens = Object.assign({}, root.notificationScreens);
                delete screens[obj.id];
                root.notificationScreens = screens;
            }
        }
    }

    property Timer _tickTimer: Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.tick++
    }
}
