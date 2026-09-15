import QtQuick
import "../../theme"

// Shared bar-item hover chrome: transparent by default (the bar itself now
// draws one continuous background, per feedback - no individual bordered
// pills), with a soft rounded highlight on hover/active. Clock/Volume/
// NowPlaying/Network/Bluetooth/NotificationBell/IdleInhibitor/PowerButton
// all wrap their content in one of these instead of redefining the same
// Rectangle + Behavior block each time.
Rectangle {
    id: root

    default property alias content: contentItem.data
    property bool active: false
    readonly property alias hovered: mouseArea.containsMouse

    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitHeight: Theme.pillHeight
    implicitWidth: contentItem.implicitWidth + Theme.spacing.md * 2
    radius: Theme.radius.control
    color: (mouseArea.containsMouse || root.active) ? Theme.bgHover : "transparent"

    Behavior on color {
        ColorAnimation { duration: Theme.motion.fast }
    }

    Item {
        id: contentItem
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    // z: -1 keeps this underneath any interactive children placed in
    // `content` so their own MouseAreas get hit-test priority instead of
    // this one swallowing every click on the item.
    MouseArea {
        id: mouseArea
        z: -1
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.wheel(wheel)
    }
}
