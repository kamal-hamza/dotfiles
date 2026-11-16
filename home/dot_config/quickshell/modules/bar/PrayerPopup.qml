import QtQuick
import Quickshell
import "../../theme"
import "../common"
import "../services"

// Body shown under the Prayer pill: the next prayer + countdown, all of
// today's times for the selected location, a location selector (IP-based
// auto-detect or a pinned city via search), and calculation-method / Asr
// juristic settings.
PopupCard {
    id: popup

    cardWidth: 300

    property bool choosingLocation: false

    onVisibleChanged: {
        if (!popup.visible) {
            popup.choosingLocation = false;
            PrayerService.search("");
        }
    }

    // ---- Header: next prayer ----

    Column {
        width: parent.width
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: PrayerService.next ? PrayerService.next.label : "Prayer times"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
            color: Theme.textSecondary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: PrayerService.next ? PrayerService.formatTime(PrayerService.next.time) : "--:--"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.display
            font.bold: true
            color: Theme.textPrimary
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !PrayerService.next || !!PrayerService.next.tomorrow
            text: PrayerService.next ? "tomorrow"
                : (PrayerService.locating ? "Detecting location…" : "Set a location below")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            color: Theme.textTertiary
        }
    }

    // ---- Sun path + current-period progress ----

    // Sun path from shortly before Fajr to shortly after Isha: a hump above
    // the horizon between sunrise and Maghrib, a shallower dip below it at
    // night. Elapsed part of the day is drawn bright, the rest dim; each
    // prayer is a marker (filled once passed) and the current moment is the
    // solid dot. Approximate by design - it's a shape, not an ephemeris.
    Canvas {
        id: sunPath

        readonly property var events: PrayerService.today
        readonly property real nowMs: PrayerService.now

        width: parent.width
        height: 84
        visible: events.length > 0

        onEventsChanged: requestPaint()
        onNowMsChanged: requestPaint()
        onWidthChanged: requestPaint()
        onVisibleChanged: if (visible) requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const ev = sunPath.events;
            if (ev.length < 6) return;

            const day = 86400000;
            const rise = ev[1].time;
            const set = ev[4].time;
            if (ev.some(p => isNaN(p.time)) || set <= rise) return;
            const start = ev[0].time - 90 * 60000;
            const end = ev[5].time + 90 * 60000;
            const span = end - start;

            const padX = 8;
            const top = 10;
            const horizonY = Math.round(sunPath.height * 0.62) + 0.5;
            const ampUp = horizonY - top;
            const ampDown = sunPath.height - 8 - horizonY;
            const nightLen = day - (set - rise);

            const xOf = t => padX + (sunPath.width - padX * 2) * (t - start) / span;
            const yOf = t => {
                if (t >= rise && t <= set)
                    return horizonY - Math.sin(Math.PI * (t - rise) / (set - rise)) * ampUp;
                const dt = t > set ? t - set : t + day - set;
                return horizonY + Math.sin(Math.PI * Math.min(1, dt / nightLen)) * ampDown;
            };

            const strokeCurve = (from, to, color, lineWidth) => {
                if (to <= from) return;
                const steps = Math.max(2, Math.ceil(120 * (to - from) / span));
                ctx.beginPath();
                for (let i = 0; i <= steps; i++) {
                    const t = from + (to - from) * i / steps;
                    if (i === 0) ctx.moveTo(xOf(t), yOf(t));
                    else ctx.lineTo(xOf(t), yOf(t));
                }
                ctx.strokeStyle = color;
                ctx.lineWidth = lineWidth;
                ctx.lineCap = "round";
                ctx.stroke();
            };

            // Horizon
            ctx.beginPath();
            ctx.moveTo(0, horizonY);
            ctx.lineTo(sunPath.width, horizonY);
            ctx.strokeStyle = "" + Theme.border;
            ctx.lineWidth = 1;
            ctx.stroke();

            const now = Math.max(start, Math.min(end, sunPath.nowMs));
            strokeCurve(start, end, "" + Theme.borderMid, 1.5);
            strokeCurve(start, now, "" + Theme.textPrimary, 2);

            // Prayer markers
            for (const p of ev) {
                const passed = p.time <= sunPath.nowMs;
                ctx.beginPath();
                ctx.arc(xOf(p.time), yOf(p.time), p.nonPrayer ? 2.5 : 3.5, 0, Math.PI * 2);
                ctx.fillStyle = passed ? "" + Theme.textPrimary : "" + Theme.bgElevated;
                ctx.fill();
                ctx.strokeStyle = passed ? "" + Theme.textPrimary : "" + Theme.borderStrong;
                ctx.lineWidth = 1.5;
                ctx.stroke();
            }

            // Now
            ctx.beginPath();
            ctx.arc(xOf(now), yOf(now), 8, 0, Math.PI * 2);
            ctx.fillStyle = Qt.rgba(1, 1, 1, 0.12);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(xOf(now), yOf(now), 4.5, 0, Math.PI * 2);
            ctx.fillStyle = "" + Theme.emphasis;
            ctx.fill();
        }
    }

    Row {
        width: parent.width
        visible: sunPath.visible

        Text {
            width: parent.width / 2
            text: "󰖜 " + PrayerService.formatTime(PrayerService.today.length > 1 ? PrayerService.today[1].time : NaN)
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
        Text {
            width: parent.width / 2
            horizontalAlignment: Text.AlignRight
            text: PrayerService.formatTime(PrayerService.today.length > 4 ? PrayerService.today[4].time : NaN) + " 󰖛"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: PrayerService.current !== null && PrayerService.upcoming !== null

        Row {
            width: parent.width

            Text {
                width: parent.width - untilLabel.implicitWidth
                text: PrayerService.current ? PrayerService.current.label : ""
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: true
            }
            Text {
                id: untilLabel
                text: PrayerService.upcoming
                    ? PrayerService.formatCountdown(PrayerService.upcoming.time) + " until " + PrayerService.upcoming.label
                    : ""
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }
        }

        Slider {
            width: parent.width
            implicitHeight: 3
            draggable: false
            value: PrayerService.periodProgress
        }
    }

    // ---- Today's times ----

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    Text {
        text: PrayerService.locationDateLabel
        color: Theme.textTertiary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.xs
        font.bold: true
    }

    Column {
        width: parent.width
        spacing: 2
        visible: PrayerService.today.length > 0

        Repeater {
            model: ScriptModel { values: PrayerService.today }

            delegate: Rectangle {
                id: prayerRow
                required property var modelData

                readonly property bool isNext: PrayerService.next !== null
                    && !PrayerService.next.tomorrow
                    && PrayerService.next.key === prayerRow.modelData.key
                readonly property bool isPast: prayerRow.modelData.time <= PrayerService.now

                width: parent ? parent.width : 260
                height: 28
                radius: Theme.radius.control
                color: prayerRow.isNext ? Theme.emphasis : "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.sm
                    text: prayerRow.modelData.label
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.sm
                    font.bold: prayerRow.isNext
                    font.italic: prayerRow.modelData.nonPrayer
                    color: prayerRow.isNext ? Theme.textOnEmphasis
                        : (prayerRow.isPast || prayerRow.modelData.nonPrayer) ? Theme.textDisabled
                        : Theme.textPrimary
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.sm
                    text: PrayerService.formatTime(prayerRow.modelData.time)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.sm
                    font.bold: prayerRow.isNext
                    color: prayerRow.isNext ? Theme.textOnEmphasis
                        : (prayerRow.isPast || prayerRow.modelData.nonPrayer) ? Theme.textDisabled
                        : Theme.textPrimary
                }
            }
        }
    }

    // ---- Location ----

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    Row {
        width: parent.width

        Text {
            width: parent.width - changeBtn.width
            text: "Location"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: changeBtn
            text: popup.choosingLocation ? "Done" : "Change"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            font.bold: true

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    popup.choosingLocation = !popup.choosingLocation;
                    if (!popup.choosingLocation) {
                        locationInput.text = "";
                        PrayerService.search("");
                    }
                }
            }
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: PrayerService.autoLocate ? "󰆤" : "󰍎"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.md
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.font.md - Theme.spacing.sm

            Text {
                width: parent.width
                elide: Text.ElideRight
                text: PrayerService.hasLocation ? PrayerService.location.name : "No location"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: true
            }
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: PrayerService.locateError !== "" ? PrayerService.locateError
                    : PrayerService.locating ? "Detecting…"
                    : [PrayerService.hasLocation ? PrayerService.location.country : "",
                       PrayerService.autoLocate ? "approx. from IP" : "pinned"].filter(s => !!s).join(" · ")
                color: Theme.textDisabled
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs
        visible: popup.choosingLocation

        Rectangle {
            width: parent.width
            height: 28
            radius: Theme.radius.control
            color: autoMa.containsMouse ? Theme.bgHover : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.sm
                text: "󰆤  Use my location (auto)"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }

            MouseArea {
                id: autoMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    PrayerService.detectLocation();
                    locationInput.text = "";
                    popup.choosingLocation = false;
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 30
            radius: Theme.radius.control
            color: Theme.bgControl
            border.width: 1
            border.color: locationInput.activeFocus ? Theme.borderHover : Theme.border

            TextInput {
                id: locationInput
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.sm
                anchors.rightMargin: Theme.spacing.sm
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                focus: popup.choosingLocation
                onTextChanged: PrayerService.search(text)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: locationInput.text.length === 0
                    text: "Search city…"
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                }
            }
        }

        Text {
            visible: PrayerService.searching
            text: "Searching…"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Text {
            visible: !PrayerService.searching && locationInput.text.length > 0 && PrayerService.searchResults.length === 0
            text: "No matches"
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: ScriptModel { values: PrayerService.searchResults }

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
                            PrayerService.chooseLocation(resultRow.modelData);
                            locationInput.text = "";
                            popup.choosingLocation = false;
                        }
                    }
                }
            }
        }
    }

    // ---- Calculation settings ----

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    component SettingRow: Rectangle {
        id: settingRow

        required property string label
        required property string valueText
        signal activated()

        width: parent ? parent.width : 260
        height: 28
        radius: Theme.radius.control
        color: settingMa.containsMouse ? Theme.bgHover : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.sm
            text: settingRow.label
            color: Theme.textTertiary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.sm
            text: settingRow.valueText + "  󰅂"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
        }

        MouseArea {
            id: settingMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: settingRow.activated()
        }
    }

    Column {
        width: parent.width
        spacing: 2

        SettingRow {
            label: "Method"
            valueText: PrayerService.methodSetting === "auto"
                ? "Auto · " + PrayerService.activeMethod.key
                : PrayerService.activeMethod.name
            onActivated: PrayerService.cycleMethod()
        }

        SettingRow {
            label: "Asr"
            valueText: PrayerService.hanafi ? "Hanafi" : "Standard"
            onActivated: PrayerService.setHanafi(!PrayerService.hanafi)
        }
    }
}
