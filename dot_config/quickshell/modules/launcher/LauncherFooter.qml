import QtQuick
import "../../theme"

// Shared footer hint row - each mode passes its own [{key, label}, ...] so
// the shortcuts shown always match what's actually active in that mode.
Row {
    id: root

    property var hints: []

    spacing: Theme.spacing.lg

    Repeater {
        model: root.hints

        delegate: Row {
            spacing: Theme.spacing.xs

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: keyText.implicitWidth + Theme.spacing.sm * 2
                implicitHeight: 18
                radius: Theme.radius.control / 2
                color: Theme.bgControl

                Text {
                    id: keyText
                    anchors.centerIn: parent
                    text: modelData.key
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    color: Theme.textSecondary
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: Theme.textTertiary
            }
        }
    }
}
