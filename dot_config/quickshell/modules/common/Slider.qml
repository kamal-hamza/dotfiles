import QtQuick
import "../../theme"

// Shared draggable horizontal slider/progress bar: AudioPopup's output and
// per-app volume rows, and NowPlayingPopup's seek bar, all use this instead
// of redefining the same track+fill+MouseArea three times.
Item {
    id: root

    property real value: 0 // 0..1
    property color fillColor: Theme.emphasis
    property color trackColor: Theme.border
    property bool draggable: true

    signal moved(real value)

    implicitHeight: 4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: height / 2
            color: root.fillColor

            Behavior on width {
                enabled: !dragArea.pressed
                NumberAnimation { duration: Theme.motion.fast }
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        anchors.topMargin: -8
        anchors.bottomMargin: -8
        enabled: root.draggable
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root._update(mouse.x)
        onPositionChanged: mouse => { if (pressed) root._update(mouse.x); }
    }

    function _update(x) {
        if (root.width <= 0) return;
        root.moved(Math.max(0, Math.min(1, x / root.width)));
    }
}
