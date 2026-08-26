import QtQuick
import Quickshell
import "../../theme"

// Dropdown shown under the clock pill: current time, day, date, and a
// calendar grid for the month. A real xdg-popup (not a second panel),
// anchored to the clock item's bottom edge - the compositor handles
// positioning it below the bar and dismissing it on an outside click or
// Escape, so there's no manual close/positioning logic to get wrong.
PopupWindow {
    id: popup

    required property var anchorWindow
    required property var anchorItem

    signal dismissed()

    visible: false
    color: "transparent"
    grabFocus: true

    anchor {
        window: anchorWindow
        item: anchorItem
        edges: Edges.Bottom
        gravity: Edges.Bottom
        margins.top: 10
    }

    implicitWidth: 240
    implicitHeight: card.implicitHeight

    onClosed: popup.dismissed()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property date today: clock.date
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()
    readonly property int dayOfMonth: today.getDate()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
    readonly property int firstWeekday: new Date(year, month, 1).getDay()

    Rectangle {
        id: card

        width: popup.implicitWidth
        implicitHeight: content.implicitHeight + 32
        radius: Theme.cardRadius
        color: Theme.background
        border.width: 1
        border.color: Theme.outline

        Column {
            id: content
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 16
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(popup.today, "hh:mm")
                font.family: Theme.fontFamily
                font.pixelSize: 26
                font.bold: true
                color: Theme.text
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(popup.today, "dddd")
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.text
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(popup.today, "MMMM d, yyyy")
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.outline
                bottomPadding: 8
            }

            Grid {
                id: calendar
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 4
                rowSpacing: 4

                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]

                    delegate: Text {
                        required property string modelData

                        width: 26
                        height: 20
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.outline
                    }
                }

                Repeater {
                    model: popup.firstWeekday + popup.daysInMonth

                    delegate: Item {
                        id: cell

                        required property int index
                        readonly property int dayNum: index - popup.firstWeekday + 1
                        readonly property bool valid: dayNum >= 1
                        readonly property bool isToday: valid && dayNum === popup.dayOfMonth

                        width: 26
                        height: 26

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: width / 2
                            visible: cell.isToday
                            color: Theme.accent
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: cell.valid
                            text: cell.dayNum
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: cell.isToday ? Theme.textOnAccent : Theme.text
                        }
                    }
                }
            }
        }
    }
}
