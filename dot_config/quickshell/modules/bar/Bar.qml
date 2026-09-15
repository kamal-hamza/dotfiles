import QtQuick
import Quickshell
import "../../theme"
import "../notifications"

// A slim top bar, one per output: clock + volume + now-playing on the left
// (matching waybar's left grouping), workspaces centered, tray/network/
// bluetooth + notifications/idle/power on the right. One continuous bar
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
        spacing: Theme.spacing.sm

        SystemTray {
            anchors.verticalCenter: parent.verticalCenter
        }
        SystemMonitor {
            id: systemMonitorWidget
        }
        Network {
            id: networkWidget
        }
        Bluetooth {
            id: bluetoothWidget
        }

        // Wider gap: status pills | quick actions.
        Item { width: Theme.spacing.md; height: 1 }

        NotificationBell {
            id: notificationBell
        }
        IdleInhibitor {
            id: idleInhibitor
            anchorWindow: bar
        }
        PowerButton {
            id: powerButton
        }
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

    AudioPopup {
        id: audioPopup
        anchorWindow: bar
        anchorItem: volumeWidget
    }

    SystemMonitorPopup {
        id: systemMonitorPopup
        anchorWindow: bar
        anchorItem: systemMonitorWidget
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
        target: systemMonitorWidget
        function onOpenChanged() { systemMonitorPopup.visible = systemMonitorWidget.open; }
    }
    Connections {
        target: systemMonitorPopup
        function onDismissed() { systemMonitorWidget.open = false; }
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
