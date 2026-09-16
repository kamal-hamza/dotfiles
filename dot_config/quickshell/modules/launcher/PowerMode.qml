import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../common"

// Power Menu: intentionally different from the other six modes - minimal,
// no search bar, large safety-oriented targets. Reuses the same
// PowerActions.qml the bar's power popup uses, so both stay in sync
// (including the destructive-confirm mechanics).
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 360

    function focusInput() {
        keyCatcher.forceActiveFocus();
        powerActions.selectedIndex = 0;
    }

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape && powerActions.anyConfirming) {
                powerActions.cancelConfirm();
                event.accepted = true;
                return;
            }
            if (root.launcher.handleGlobalKeys(event)) { event.accepted = true; return; }
            if (root.launcher.isNext(event)) {
                powerActions.selectNext();
                event.accepted = true;
            } else if (root.launcher.isPrevious(event)) {
                powerActions.selectPrevious();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                powerActions.activateSelected();
                event.accepted = true;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacing.lg

            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Power"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xl
                font.bold: true
                color: Theme.textPrimary
            }

            PowerActions {
                id: powerActions
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 260
                rowHeight: 44
                glyphSize: Theme.font.lg
                labelSize: Theme.font.md
            }

            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

            LauncherFooter {
                Layout.alignment: Qt.AlignHCenter
                hints: [
                    { key: "↑↓", label: "Navigate" },
                    { key: "↵", label: "Select" },
                    { key: "Tab", label: "Modes" },
                    { key: "Esc", label: "Close" }
                ]
            }

            Item { Layout.preferredHeight: Theme.spacing.sm }
        }
    }
}
