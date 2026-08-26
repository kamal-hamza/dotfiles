import QtQuick
import Quickshell
import "../../theme"

// A slim top bar, one per output: clock + volume on the left, now-playing
// centered, workspace switcher on the right. The bar itself is
// transparent - only individual widgets draw a pill background, like
// waybar's setup. New bar widgets get added here.
PanelWindow {
    id: bar

    // Set as an initial property by the Variants { model: Quickshell.screens }
    // instantiation in shell.qml.
    required property var modelData

    screen: modelData

    color: "transparent"
    implicitHeight: Theme.barHeight

    // Reserve screen space equal to implicitHeight so windows don't
    // tile underneath the bar.
    exclusionMode: ExclusionMode.Auto

    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Clock {
            id: clockWidget
        }
        Volume {}
    }

    NowPlaying {
        id: nowPlayingWidget
        anchors.centerIn: parent
    }

    Workspaces {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        screen: bar.screen
    }

    CalendarPopup {
        id: calendarPopup
        anchorWindow: bar
        anchorItem: clockWidget
    }

    NowPlayingPopup {
        id: nowPlayingPopup
        anchorWindow: bar
        anchorItem: nowPlayingWidget
    }

    // Imperative, not a plain binding: the compositor can dismiss a
    // popup on its own (outside click / Escape), which would silently
    // break a declarative "visible: widget.open" binding. Syncing both
    // directions through signals keeps them consistent regardless of
    // which side changes first.
    Connections {
        target: clockWidget
        function onOpenChanged() {
            calendarPopup.visible = clockWidget.open;
        }
    }

    Connections {
        target: calendarPopup
        function onDismissed() {
            clockWidget.open = false;
        }
    }

    Connections {
        target: nowPlayingWidget
        function onOpenChanged() {
            nowPlayingPopup.visible = nowPlayingWidget.open;
        }
    }

    Connections {
        target: nowPlayingPopup
        function onDismissed() {
            nowPlayingWidget.open = false;
        }
    }
}
