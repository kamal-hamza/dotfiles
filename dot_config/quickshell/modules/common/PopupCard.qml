import QtQuick
import Quickshell
import "../../theme"

// Shared popup chrome: every dropdown (calendar, now-playing, audio,
// network, bluetooth, notification center, power menu, system monitor) is
// one of these instead of hand-rolling its own PopupWindow + card
// Rectangle, so they all share the same radius/border/background and open
// animation.
//
// Entrance-only animation: a PopupWindow's Wayland surface unmaps the
// instant `visible` goes false, so there is nothing left on screen to
// animate an exit against - only the scale/fade-in on open is real.
PopupWindow {
    id: popup

    required property var anchorWindow
    required property var anchorItem

    property int cardWidth: 300
    property int edgeMargin: 10
    default property alias content: column.data

    signal dismissed()

    visible: false
    color: "transparent"
    grabFocus: true

    anchor {
        window: popup.anchorWindow
        item: popup.anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: popup.edgeMargin
    }

    implicitWidth: popup.cardWidth
    implicitHeight: card.implicitHeight

    onClosed: popup.dismissed()

    Rectangle {
        id: card

        width: popup.cardWidth
        implicitHeight: column.implicitHeight + Theme.spacing.lg * 2
        radius: Theme.radius.card
        color: Theme.bgElevated
        border.width: 1
        border.color: Theme.border

        scale: popup.visible ? 1 : 0.96
        opacity: popup.visible ? 1 : 0

        Behavior on scale {
            NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve }
        }
        Behavior on opacity {
            NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve }
        }

        Column {
            id: column
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.spacing.lg
            width: popup.cardWidth - Theme.spacing.lg * 2
            spacing: Theme.spacing.md
        }
    }
}
