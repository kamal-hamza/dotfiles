import QtQuick
import Quickshell
import "../../theme"
import "../common"
import "../services"

// Body shown under the clock pill: current time, day, date, a calendar
// grid for the month, and a world-clocks + weather section (up to 8 cities,
// searchable via Open-Meteo's free geocoding API - no key required).
PopupCard {
    id: popup

    cardWidth: 300

    property bool addingCity: false

    onVisibleChanged: {
        if (!popup.visible) {
            popup.addingCity = false;
            WeatherService.search("");
        }
    }

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

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(popup.today, "hh:mm")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.display
        font.bold: true
        color: Theme.textPrimary
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(popup.today, "dddd")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: Theme.textPrimary
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(popup.today, "MMMM d, yyyy")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
        color: Theme.textTertiary
        bottomPadding: Theme.spacing.sm
    }

    Grid {
        anchors.horizontalCenter: parent.horizontalCenter
        columns: 7
        columnSpacing: Theme.spacing.xs
        rowSpacing: Theme.spacing.xs

        Repeater {
            model: ["S", "M", "T", "W", "T", "F", "S"]

            delegate: Text {
                required property string modelData

                width: 26
                height: 20
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: true
                color: Theme.textTertiary
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
                    color: Theme.emphasis
                }

                Text {
                    anchors.centerIn: parent
                    visible: cell.valid
                    text: cell.dayNum
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.sm
                    color: cell.isToday ? Theme.textOnEmphasis : Theme.textPrimary
                }
            }
        }
    }

    // ---- World clocks + weather ----

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    Row {
        width: parent.width

        Text {
            width: parent.width - addBtn.width
            text: "World clocks"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: addBtn
            text: popup.addingCity ? "" : "+"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.sm
            font.bold: true

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                enabled: WeatherService.cities.length < WeatherService.maxCities
                onClicked: {
                    popup.addingCity = !popup.addingCity;
                    if (!popup.addingCity) WeatherService.search("");
                }
            }
        }
    }

    Text {
        visible: WeatherService.cities.length === 0 && !popup.addingCity
        text: "No cities added yet"
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.xs
    }

    Column {
        width: parent.width
        spacing: 2
        visible: WeatherService.cities.length > 0

        Repeater {
            model: ScriptModel { values: WeatherService.cities }

            delegate: Rectangle {
                id: cityRow
                required property var modelData
                required property int index

                readonly property var weather: WeatherService.weatherFor(cityRow.modelData)

                width: parent ? parent.width : 260
                height: 34
                radius: Theme.radius.control
                color: cityMa.containsMouse ? Theme.bgHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                MouseArea {
                    id: cityMa
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.sm
                    spacing: 2

                    Column {
                        Text {
                            text: cityRow.modelData.name
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            font.bold: true
                        }
                        Text {
                            text: cityRow.modelData.country
                            color: Theme.textDisabled
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.sm
                    spacing: Theme.spacing.sm

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: cityRow.weather
                            ? WeatherService.weatherGlyph(cityRow.weather.code) + " " + Math.round(cityRow.weather.tempC) + "°"
                            : "…"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: WeatherService.localTimeFor(cityRow.modelData)
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.sm
                        font.bold: true
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: WeatherService.cities.length > 1
                        Text {
                            text: "󰅃"
                            color: cityRow.index > 0 ? Theme.textTertiary : Theme.textDisabled
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WeatherService.moveCity(cityRow.index, -1)
                            }
                        }
                        Text {
                            text: "󰅀"
                            color: cityRow.index < WeatherService.cities.length - 1 ? Theme.textTertiary : Theme.textDisabled
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WeatherService.moveCity(cityRow.index, 1)
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        color: Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.sm

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: WeatherService.removeCity(cityRow.index)
                        }
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: popup.addingCity

        Rectangle {
            width: parent.width
            height: 30
            radius: Theme.radius.control
            color: Theme.bgControl
            border.width: 1
            border.color: cityInput.activeFocus ? Theme.borderHover : Theme.border

            TextInput {
                id: cityInput
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.sm
                anchors.rightMargin: Theme.spacing.sm
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                focus: popup.addingCity
                onTextChanged: WeatherService.search(text)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: cityInput.text.length === 0
                    text: "Search city or country…"
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
            }
        }

        Text {
            visible: WeatherService.searching
            text: "Searching…"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Text {
            visible: !WeatherService.searching && cityInput.text.length > 0 && WeatherService.searchResults.length === 0
            text: "No matches"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: ScriptModel { values: WeatherService.searchResults }

                delegate: Rectangle {
                    id: resultRow
                    required property var modelData

                    width: parent ? parent.width : 260
                    height: 28
                    radius: Theme.radius.control
                    color: resultMa.containsMouse ? Theme.bgHover : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Theme.spacing.sm
                        elide: Text.ElideRight
                        text: resultRow.modelData.name
                            + (resultRow.modelData.admin1 ? ", " + resultRow.modelData.admin1 : "")
                            + (resultRow.modelData.country ? ", " + resultRow.modelData.country : "")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                    }

                    MouseArea {
                        id: resultMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WeatherService.addCity(resultRow.modelData);
                            cityInput.text = "";
                            popup.addingCity = false;
                        }
                    }
                }
            }
        }
    }
}
