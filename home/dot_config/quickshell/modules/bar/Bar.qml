import QtQuick
import Quickshell
import "../../theme"
import "../notifications"

// A slim top bar, one per output: clock/prayer/volume/now-playing on the
// left, workspaces centered, evenly spaced icons on the right (connectivity,
// night light, notifications + power). One continuous bar
// surface (not per-module pills) - widgets sit directly on it and only get
// a soft highlight on hover/active. New bar widgets get added here.
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

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Theme.border
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.lg
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.sm

        Clock {
            id: clockWidget
        }
        Prayer {
            id: prayerWidget
        }
        Volume {
            id: volumeWidget
        }
        NowPlaying {
            id: nowPlayingWidget
        }
    }

    Workspaces {
        id: workspacesWidget
        anchors.centerIn: parent
        screen: bar.screen
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.lg
        anchors.verticalCenter: parent.verticalCenter

        Network {
            id: networkWidget
            minWidth: Theme.barIconSlot
        }
        Bluetooth {
            id: bluetoothWidget
            minWidth: Theme.barIconSlot
        }
        NightLight {
            id: nightLight
            minWidth: Theme.barIconSlot
        }
        NotificationBell {
            id: notificationBell
            minWidth: Theme.barIconSlot
        }
        PowerButton {
            id: powerButton
            minWidth: Theme.barIconSlot
        }
    }

    CalendarPopup {
        id: calendarPopup
        anchorWindow: bar
        anchorItem: clockWidget
    }

    PrayerPopup {
        id: prayerPopup
        anchorWindow: bar
        anchorItem: prayerWidget
    }

    NowPlayingPopup {
        id: nowPlayingPopup
        anchorWindow: bar
        anchorItem: nowPlayingWidget
    }

    AudioPopup {
        id: audioPopup
        anchorWindow: bar
        anchorItem: volumeWidget
    }

    NetworkPopup {
        id: networkPopup
        anchorWindow: bar
        anchorItem: networkWidget
    }

    BluetoothPopup {
        id: bluetoothPopup
        anchorWindow: bar
        anchorItem: bluetoothWidget
    }

    NotificationCenter {
        id: notificationCenterPopup
        anchorWindow: bar
        anchorItem: notificationBell
    }

    PowerMenu {
        id: powerMenuPopup
        anchorWindow: bar
        anchorItem: powerButton
    }

    // Imperative, not a plain binding: the compositor can dismiss a
    // popup on its own (outside click / Escape), which would silently
    // break a declarative "visible: widget.open" binding. Syncing both
    // directions through signals keeps them consistent regardless of
    // which side changes first.
    Connections {
        target: clockWidget
        function onOpenChanged() { calendarPopup.visible = clockWidget.open; }
    }
    Connections {
        target: calendarPopup
        function onDismissed() { clockWidget.open = false; }
    }

    Connections {
        target: prayerWidget
        function onOpenChanged() { prayerPopup.visible = prayerWidget.open; }
    }
    Connections {
        target: prayerPopup
        function onDismissed() { prayerWidget.open = false; }
    }

    Connections {
        target: nowPlayingWidget
        function onOpenChanged() { nowPlayingPopup.visible = nowPlayingWidget.open; }
    }
    Connections {
        target: nowPlayingPopup
        function onDismissed() { nowPlayingWidget.open = false; }
    }

    Connections {
        target: volumeWidget
        function onOpenChanged() { audioPopup.visible = volumeWidget.open; }
    }
    Connections {
        target: audioPopup
        function onDismissed() { volumeWidget.open = false; }
    }

    Connections {
        target: networkWidget
        function onOpenChanged() { networkPopup.visible = networkWidget.open; }
    }
    Connections {
        target: networkPopup
        function onDismissed() { networkWidget.open = false; }
    }

    Connections {
        target: bluetoothWidget
        function onOpenChanged() { bluetoothPopup.visible = bluetoothWidget.open; }
    }
    Connections {
        target: bluetoothPopup
        function onDismissed() { bluetoothWidget.open = false; }
    }

    Connections {
        target: notificationBell
        function onOpenChanged() { notificationCenterPopup.visible = notificationBell.open; }
    }
    Connections {
        target: notificationCenterPopup
        function onDismissed() { notificationBell.open = false; }
    }

    Connections {
        target: powerButton
        function onOpenChanged() { powerMenuPopup.visible = powerButton.open; }
    }
    Connections {
        target: powerMenuPopup
        function onDismissed() { powerButton.open = false; }
    }
}
