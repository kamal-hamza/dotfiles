import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import "../../theme"

// Single notification card, used both as a floating toast (mode: "popup")
// and as a row in the notification center (mode: "center") instead of two
// near-duplicate components - only the animation/timer/close-button/
// timestamp behavior differs by mode.
Rectangle {
    id: card

    required property var notif
    property string mode: "popup" // "popup" | "center"

    readonly property bool isPopup: mode === "popup"
    readonly property bool isCenter: mode === "center"

    width: 320
    implicitHeight: layoutColumn.implicitHeight + Theme.spacing.md * 2
    height: implicitHeight
    radius: Theme.radius.control
    color: Theme.bgControl
    border.width: 1
    border.color: Theme.border

    readonly property bool isCritical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property bool isLow: notif && notif.urgency === NotificationUrgency.Low
    readonly property bool isSticky: isCritical || (notif && notif.expireTimeout === 0)

    readonly property real timeoutSeconds: {
        if (!notif) return 5;
        if (notif.expireTimeout > 0) return notif.expireTimeout / 1000;
        return 5;
    }

    readonly property string appIconSrc: notif && notif.appIcon ? Quickshell.iconPath(notif.appIcon, true) : ""
    readonly property string bodyImageSrc: notif && notif.image ? NotificationService.resolveImage(notif.image) : ""
    readonly property var defaultAction: NotificationService.defaultActionFor(notif)

    // ---- Entrance animation (popup mode only) ----
    state: "shown"
    states: [
        State {
            name: "hidden"
            PropertyChanges { target: card; opacity: 0; x: 24 }
        },
        State {
            name: "shown"
            PropertyChanges { target: card; opacity: 1; x: 0 }
        }
    ]
    transitions: Transition {
        NumberAnimation { properties: "x,opacity"; duration: Theme.motion.base; easing.type: Theme.motion.curve }
    }

    Component.onCompleted: {
        if (card.isPopup) {
            state = "hidden";
            Qt.callLater(() => card.state = "shown");
        }
    }

    // ---- Auto-dismiss (popup mode only), paused while hovered ----
    Timer {
        id: dismissTimer
        interval: card.timeoutSeconds * 1000
        running: card.isPopup && !card.isSticky && !cardHover.containsMouse
        repeat: false
        onTriggered: {
            if (card.notif) NotificationService.removeFromPopup(card.notif.id);
        }
    }

    // ---- Urgency stripe ----
    Rectangle {
        visible: card.isCritical || card.isLow
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 1 }
        width: 3
        radius: 1
        color: card.isCritical ? Theme.emphasis : Theme.textDisabled
    }

    MouseArea {
        id: cardHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: -1
        onClicked: {
            if (!card.notif) return;
            if (card.defaultAction) {
                card.defaultAction.invoke();
                if (!card.notif.resident) card.notif.dismiss();
            }
        }
    }

    Column {
        id: layoutColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.spacing.md
            leftMargin: (card.isCritical || card.isLow) ? Theme.spacing.md + 6 : Theme.spacing.md
        }
        spacing: Theme.spacing.xs

        Row {
            id: headerRow
            width: parent.width
            spacing: Theme.spacing.xs
            height: 16

            Item {
                width: card.appIconSrc !== "" ? 14 : 0
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: card.appIconSrc !== ""

                IconImage {
                    anchors.fill: parent
                    implicitSize: 14
                    source: card.appIconSrc
                    asynchronous: false
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                    - (card.appIconSrc !== "" ? 14 + parent.spacing : 0)
                    - closeBtn.width - parent.spacing
                    - (timeText.visible ? timeText.implicitWidth + parent.spacing : 0)
                text: card.notif ? (card.notif.appName || "Notification") : ""
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                elide: Text.ElideRight
            }

            Text {
                id: timeText
                anchors.verticalCenter: parent.verticalCenter
                visible: card.isCenter && card.notif !== null
                text: card.notif ? NotificationService.relativeTime(card.notif.id) : ""
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
            }

            Rectangle {
                id: closeBtn
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                radius: 8
                color: closeMa.containsMouse ? Theme.bgHover : "transparent"
                opacity: card.isCenter || cardHover.containsMouse ? 1 : 0.35
                Behavior on opacity { NumberAnimation { duration: Theme.motion.fast } }
                Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅖" // nf-md-close
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (card.notif) card.notif.dismiss();
                    }
                }
            }
        }

        Item {
            width: parent.width
            implicitHeight: Math.max(textColumn.implicitHeight, bodyImage.shown ? 40 : 0)

            Column {
                id: textColumn
                anchors {
                    left: parent.left
                    right: bodyImage.shown ? bodyImage.left : parent.right
                    top: parent.top
                    rightMargin: bodyImage.shown ? Theme.spacing.sm : 0
                }
                spacing: 2

                Text {
                    width: parent.width
                    text: card.notif ? card.notif.summary : ""
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.md
                    font.bold: true
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    visible: text.length > 0
                }
                Text {
                    width: parent.width
                    text: card.notif ? card.notif.body : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.sm
                    wrapMode: Text.WordWrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }

            Item {
                id: bodyImage
                anchors.right: parent.right
                anchors.top: parent.top

                readonly property bool shown: card.bodyImageSrc !== "" && bodyImg.status === Image.Ready

                width: shown ? 40 : 0
                height: 40
                visible: shown

                IconImage {
                    id: bodyImg
                    width: 40
                    height: 40
                    implicitSize: 40
                    source: card.bodyImageSrc
                    asynchronous: true
                }
            }
        }

        Row {
            visible: card.notif && card.notif.actions && actionsRepeater.count > 0
            spacing: Theme.spacing.xs
            height: visible ? 24 : 0

            Repeater {
                id: actionsRepeater
                model: card.notif ? card.notif.actions : []

                delegate: Rectangle {
                    required property var modelData
                    visible: modelData && modelData.identifier !== "default"
                    width: actionLabel.implicitWidth + Theme.spacing.md
                    height: visible ? 24 : 0
                    radius: Theme.radius.control
                    color: actionMa.containsMouse ? Theme.emphasis : Theme.bgHover
                    border.width: 1
                    border.color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: parent.modelData ? parent.modelData.text : ""
                        color: actionMa.containsMouse ? Theme.textOnEmphasis : Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        font.bold: true
                    }

                    MouseArea {
                        id: actionMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (parent.modelData) parent.modelData.invoke();
                            if (card.notif && !card.notif.resident) card.notif.dismiss();
                        }
                    }
                }
            }
        }
    }
}
