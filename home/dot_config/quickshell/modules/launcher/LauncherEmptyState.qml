import QtQuick
import "../../theme"

// Shared "deliberate empty state" block - every mode uses this instead of
// leaving a blank results area.
Column {
    id: root

    property string title: ""
    property string subtitle: ""

    anchors.centerIn: parent
    spacing: Theme.spacing.xs

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        color: Theme.textSecondary
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.subtitle.length > 0
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.sm
        color: Theme.textTertiary
        horizontalAlignment: Text.AlignHCenter
        width: 300
        wrapMode: Text.WordWrap
    }
}
