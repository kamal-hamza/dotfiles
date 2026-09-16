import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

// Calculator: a thin, live-updating shell around `qalc` (libqalculate) -
// arithmetic, unit conversion, constants, functions, hex/binary all work
// for free since qalc already supports them natively.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 320

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    property string resultText: ""
    property bool hasError: false
    property bool hasResult: false

    Timer {
        id: debounce
        interval: 150
        onTriggered: root._evaluate()
    }
    Connections {
        target: searchBar.input
        function onTextChanged() { debounce.restart(); }
    }

    Process {
        id: qalcProc
        stdout: StdioCollector { id: outCollector }
        stderr: StdioCollector { id: errCollector }
        onExited: (code, status) => {
            const out = outCollector.text.trim();
            const err = errCollector.text.trim();
            if (out !== "") {
                root.resultText = out;
                root.hasError = false;
                root.hasResult = true;
            } else {
                root.resultText = err !== "" ? err : "No result";
                root.hasError = true;
                root.hasResult = false;
            }
        }
    }
    Process { id: copyProc }

    function _evaluate() {
        const expr = searchBar.text.trim();
        if (expr === "") {
            root.resultText = "";
            root.hasError = false;
            root.hasResult = false;
            return;
        }
        qalcProc.command = ["qalc", "-t", expr];
        qalcProc.running = true;
    }
    function _copy() {
        if (!root.hasResult) return;
        copyProc.command = ["wl-copy", root.resultText];
        copyProc.running = true;
        root.launcher.close();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "√"
            modeLabel: "Calc"
            placeholder: "Type an expression... e.g. sqrt(42), 10MiB to MB"

            input.font.family: "monospace"

            input.Keys.onPressed: event => {
                if (root.launcher.handleGlobalKeys(event)) { event.accepted = true; return; }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root._copy();
                    event.accepted = true;
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacing.sm
                visible: root.resultText.length > 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.resultText
                    font.family: root.hasError ? Theme.fontFamily : "monospace"
                    font.pixelSize: root.hasError ? Theme.font.md : Theme.font.display
                    font.bold: !root.hasError
                    color: root.hasError ? Theme.textTertiary : Theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    width: root.width - Theme.spacing.lg * 2
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.hasResult
                    text: "Press Enter to copy"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    color: Theme.textTertiary
                }
            }

            LauncherEmptyState {
                visible: root.resultText.length === 0
                title: "Everything qalc supports, live"
                subtitle: "sqrt(42) · 128 * 42 · 10MiB to MB · 5 ft to cm · 2^32 · sin(pi/4)"
            }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: [
                { key: "↵", label: "Copy result" },
                { key: "Tab", label: "Modes" },
                { key: "Esc", label: "Close" }
            ]
        }
    }
}
