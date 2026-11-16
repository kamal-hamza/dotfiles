import QtQuick
import "../../theme"
import "../common"
import "../notifications"

// Bell pill. Left-click toggles the notification center; right-click
// toggles do-not-disturb (Critical urgency still always gets through).
Pill {
    id: root

    property bool open: false

    readonly property int count: NotificationService.trackedNotifications
        ? NotificationService.trackedNotifications.values.length : 0
    readonly property bool dnd: NotificationService.dndEnabled

    active: root.open

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) root.open = !root.open;
        else if (mouse.button === Qt.RightButton) NotificationService.toggleDnd();
    }

    Item {
        width: 18
        height: 18

        Text {
            anchors.centerIn: parent
            text: root.dnd ? "󰂛" : "󰂚" // nf-md-bell-off / nf-md-bell
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
        }

        Rectangle {
            visible: root.count > 0 && !root.dnd
            anchors { right: parent.right; top: parent.top; rightMargin: -3; topMargin: -3 }
            width: Math.max(12, badgeText.implicitWidth + 6)
            height: 12
            radius: 6
            color: Theme.emphasis
            border.width: 1
            border.color: Theme.bg

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: root.count > 9 ? "9+" : root.count
                color: Theme.textOnEmphasis
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }
    }
}
