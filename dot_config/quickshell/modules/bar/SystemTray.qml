import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../theme"

// Native tray icons (StatusNotifierItems) - fills a real gap neither
// Waybar's config nor the old bar had: apps that only live in the tray.
// Left-click activates, middle-click secondary-activates, scroll adjusts
// where supported, right-click opens the item's own menu via QsMenuAnchor
// (native rendering - menu content comes from arbitrary third-party apps,
// so matching our exact chrome there is out of scope). Collapses to
// nothing when no tray items are registered.
Row {
    id: root

    spacing: Theme.spacing.sm

    Repeater {
        model: SystemTray.items ? SystemTray.items.values : []

        delegate: Item {
            id: trayItem
            required property var modelData

            width: 18
            height: 18

            // Unwraps the `icon?path=<dir>` XDG StatusNotifierItem
            // extension and the `image://icon/` prefix Quickshell otherwise
            // wraps theme-name icons in - same family of gotcha as the
            // notification image-hint quirk.
            readonly property string _iconSource: {
                const raw = trayItem.modelData && trayItem.modelData.icon ? String(trayItem.modelData.icon) : "";
                if (!raw) return "";
                if (raw.indexOf("?path=") >= 0) {
                    const parts = raw.split("?path=");
                    const name = parts[0].replace("image://icon/", "");
                    return "file://" + parts[1] + "/" + name;
                }
                if (raw.indexOf("image://") === 0 || raw.indexOf("/") === 0 || raw.indexOf("file:") === 0)
                    return raw;
                return "image://icon/" + raw.replace(/-symbolic$/, "");
            }

            IconImage {
                anchors.fill: parent
                implicitSize: 18
                source: trayItem._iconSource
                asynchronous: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItem.modelData ? trayItem.modelData.menu : null
                anchor.item: trayItem
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: mouse => {
                    if (!trayItem.modelData) return;
                    if (mouse.button === Qt.LeftButton) trayItem.modelData.activate();
                    else if (mouse.button === Qt.MiddleButton) trayItem.modelData.secondaryActivate();
                    else if (mouse.button === Qt.RightButton && menuAnchor.menu) menuAnchor.open();
                }
                onWheel: wheel => {
                    if (trayItem.modelData) trayItem.modelData.scroll(wheel.angleDelta.y, false);
                }
            }
        }
    }
}
