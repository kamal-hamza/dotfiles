import QtQuick

// Single-line label that scrolls back and forth when its text is wider
// than the space it's given, instead of eliding - used for track titles/
// artists (NowPlaying, NowPlayingPopup, SeekOsd) where the cut-off part is
// usually the bit you wanted to read. Behaves like a plain Text when it
// fits: implicitWidth is the full text width, so callers can still clamp
// with `width: Math.min(implicitWidth, max)`.
Item {
    id: root

    property alias text: label.text
    property alias font: label.font
    property alias color: label.color
    // Only matters when the text fits; an overflowing label always starts
    // flush left so the scroll reads naturally.
    property int horizontalAlignment: Text.AlignLeft
    // Lets callers pause the animation while hidden (e.g. a closed popup).
    property bool running: true
    property real pixelsPerSecond: 30
    property int pauseMs: 1500

    readonly property real overflow: Math.max(0, label.implicitWidth - root.width)
    readonly property bool overflowing: root.overflow > 1

    readonly property real _restX: {
        if (root.overflowing) return 0;
        if (root.horizontalAlignment === Text.AlignHCenter) return (root.width - label.implicitWidth) / 2;
        if (root.horizontalAlignment === Text.AlignRight) return root.width - label.implicitWidth;
        return 0;
    }

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    clip: true

    Text {
        id: label
        x: root._restX
        anchors.verticalCenter: parent.verticalCenter
    }

    // `to`/`duration` are read once when the animation starts, so any change
    // to the text or available width restarts it from the left edge.
    function _restart() {
        scroll.stop();
        label.x = Qt.binding(() => root._restX);
        if (root.overflowing && root.running && root.visible) scroll.start();
    }

    onOverflowChanged: root._restart()
    onTextChanged: root._restart()
    onRunningChanged: root._restart()
    onVisibleChanged: root._restart()
    Component.onCompleted: root._restart()

    SequentialAnimation {
        id: scroll
        loops: Animation.Infinite

        PauseAnimation { duration: root.pauseMs }
        NumberAnimation {
            target: label
            property: "x"
            from: 0
            to: -root.overflow
            duration: root.overflow / root.pixelsPerSecond * 1000
            easing.type: Easing.InOutSine
        }
        PauseAnimation { duration: root.pauseMs }
        NumberAnimation {
            target: label
            property: "x"
            from: -root.overflow
            to: 0
            duration: root.overflow / root.pixelsPerSecond * 1000
            easing.type: Easing.InOutSine
        }
    }
}
