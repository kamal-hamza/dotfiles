import QtQuick
import Quickshell
import "../../theme"
import "../common"

// Body shown from NotificationBell: every tracked notification, newest
// first, plus a clear-all action.
PopupCard {
    id: popup

    cardWidth: 340

    readonly property var _sorted: {
        const list = NotificationService.trackedNotifications
            ? NotificationService.trackedNotifications.values.slice() : [];
        list.reverse();
        return list;
    }

    Row {
        width: parent.width
        height: 20

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - clearAllText.implicitWidth - Theme.spacing.sm
            text: "Notifications"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
            font.bold: true
        }

        Text {
            id: clearAllText
            anchors.verticalCenter: parent.verticalCenter
            visible: popup._sorted.length > 0
            text: "Clear all"
            color: clearMa.containsMouse ? Theme.textStrong : Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs

            MouseArea {
                id: clearMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationService.clearAll()
            }
        }
    }

    Text {
        visible: popup._sorted.length === 0
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "No notifications"
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
        topPadding: Theme.spacing.md
        bottomPadding: Theme.spacing.md
    }

    Flickable {
        width: parent.width
        height: Math.min(contentColumn.implicitHeight, 420)
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        visible: popup._sorted.length > 0
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.spacing.sm

            Repeater {
                model: ScriptModel { values: popup._sorted }
                delegate: NotificationCard {
                    required property var modelData
                    width: parent ? parent.width : 320
                    notif: modelData
                    mode: "center"
                }
            }
        }
    }
}
