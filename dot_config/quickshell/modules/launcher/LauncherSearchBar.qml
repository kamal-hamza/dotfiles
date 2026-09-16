import QtQuick
import QtQuick.Layouts
import "../../theme"

// Shared search-bar chrome for every launcher mode: mode chip, text input
// with placeholder, live result count, and a clear button. Each mode owns
// its own instance (and therefore its own TextInput/text), which is what
// makes a mode's query survive Tab-cycling away and back without any extra
// state plumbing in Launcher.qml.
Item {
    id: root

    required property string glyph
    required property string modeLabel
    property string placeholder: ""
    property alias text: input.text
    property alias input: input
    property string countText: ""

    implicitHeight: 48

    function focusInput() { input.forceActiveFocus(); }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius.control
        color: Theme.bgControl
        border.width: 1
        border.color: input.activeFocus ? Theme.borderHover : Theme.border

        Behavior on border.color { ColorAnimation { duration: Theme.motion.fast } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            spacing: Theme.spacing.sm

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: chipText.implicitWidth + Theme.spacing.sm * 2
                implicitHeight: 24
                radius: Theme.radius.pill
                color: Theme.bgHover

                Text {
                    id: chipText
                    anchors.centerIn: parent
                    text: root.glyph + "  " + root.modeLabel
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    font.bold: true
                    color: Theme.textSecondary
                }
            }

            TextInput {
                id: input
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.md
                color: Theme.textPrimary
                clip: true
                selectByMouse: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.placeholder
                    visible: !parent.text
                    font: parent.font
                    color: Theme.textTertiary
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                visible: root.countText.length > 0
                text: root.countText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: Theme.textTertiary
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                visible: input.text.length > 0
                text: "×"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.lg
                color: clearMa.containsMouse ? Theme.textPrimary : Theme.textTertiary

                MouseArea {
                    id: clearMa
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: input.text = ""
                }
            }
        }
    }
}
