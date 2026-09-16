import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

// Command Launcher: a developer command palette, not a terminal emulator.
// Enter streams stdout/stderr live into a scrollback pane (rofi's run mode
// is fire-and-forget with no visible output - this is the improvement);
// Ctrl+Enter hands the command off to an interactive terminal instead.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 520

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    property bool hasRun: false
    property string runCommand: ""
    property string status: "idle" // idle | running | success | failure
    property int exitCode: -1
    property var outputLines: []
    property bool userScrolled: false
    property int historyIndex: -1

    function _appendOutput(line) {
        root.outputLines = root.outputLines.concat([line]).slice(-2000);
    }

    Process {
        id: proc
        stdout: SplitParser { onRead: line => root._appendOutput(line) }
        stderr: SplitParser { onRead: line => root._appendOutput(line) }
        onExited: (code, exitStatus) => {
            root.status = code === 0 ? "success" : "failure";
            root.exitCode = code;
        }
    }
    Process { id: terminalProc }
    Process { id: copyProc }

    function _run(cmd) {
        cmd = (cmd || "").trim();
        if (cmd === "" || root.status === "running") return;
        root.hasRun = true;
        root.runCommand = cmd;
        root.outputLines = [];
        root.userScrolled = false;
        root.status = "running";
        root.exitCode = -1;
        root.launcher.pushRecentCommand(cmd);
        root.historyIndex = -1;
        proc.command = ["bash", "-lc", cmd];
        proc.running = true;
    }
    function _runInTerminal(cmd) {
        cmd = (cmd || "").trim();
        if (cmd === "") return;
        root.launcher.pushRecentCommand(cmd);
        terminalProc.command = ["ghostty", "-e", "bash", "-lc", cmd + "; exec bash"];
        terminalProc.startDetached();
        root.launcher.close();
    }
    function _copyOutput() {
        copyProc.command = ["wl-copy", root.outputLines.join("\n")];
        copyProc.running = true;
    }
    function _clearOutput() {
        root.outputLines = [];
        root.hasRun = false;
        root.status = "idle";
        root.exitCode = -1;
    }
    // Guards the recall functions' own searchBar.text assignment from
    // being mistaken for the user typing, which would otherwise reset
    // historyIndex right back to -1 via the Connections below.
    property bool _recalling: false

    // Up/Ctrl+P moves the highlight up the (newest-first) list, toward the
    // most recent command and eventually clearing; Down/Ctrl+N moves it
    // down, toward older ones - same up/down-means-up/down-on-screen
    // convention every other mode's list navigation uses.
    function _recallPrev() {
        root._recalling = true;
        if (root.historyIndex <= 0) {
            root.historyIndex = -1;
            searchBar.text = "";
        } else {
            root.historyIndex -= 1;
            recentList.positionViewAtIndex(root.historyIndex, ListView.Contain);
            searchBar.text = root.launcher.state.recentCommands[root.historyIndex];
        }
        root._recalling = false;
    }
    function _recallNext() {
        const hist = root.launcher.state.recentCommands;
        if (hist.length === 0) return;
        root.historyIndex = Math.min(root.historyIndex + 1, hist.length - 1);
        recentList.positionViewAtIndex(root.historyIndex, ListView.Contain);
        root._recalling = true;
        searchBar.text = hist[root.historyIndex];
        root._recalling = false;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "$"
            modeLabel: "Run"
            placeholder: "> Run a command..."

            input.font.family: "monospace"

            Connections {
                target: searchBar.input
                function onTextChanged() { if (!root._recalling) root.historyIndex = -1; }
            }

            input.Keys.onPressed: event => {
                if (root.launcher.handleGlobalKeys(event)) { event.accepted = true; return; }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (event.modifiers & Qt.ControlModifier) root._runInTerminal(searchBar.text);
                    else root._run(searchBar.text);
                    event.accepted = true;
                } else if (root.launcher.isPrevious(event)) {
                    root._recallPrev();
                    event.accepted = true;
                } else if (root.launcher.isNext(event)) {
                    root._recallNext();
                    event.accepted = true;
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Recent commands (shown while nothing has run yet this session)
            ColumnLayout {
                anchors.fill: parent
                visible: !root.hasRun
                spacing: Theme.spacing.sm

                Text {
                    text: "Recent commands"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.font.xs
                    color: Theme.textTertiary
                    visible: root.launcher.state.recentCommands.length > 0
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: recentList
                        anchors.fill: parent
                        clip: true
                        spacing: 2
                        model: root.launcher.state.recentCommands
                        currentIndex: root.historyIndex

                        delegate: Rectangle {
                            id: recentRow
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            height: 32
                            radius: Theme.radius.control
                            color: recentRow.index === root.historyIndex ? Theme.bgHover : (recentMa.containsMouse ? Theme.bgHover : "transparent")

                            Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: Theme.spacing.sm
                                text: "$ " + recentRow.modelData
                                font.family: "monospace"
                                font.pixelSize: Theme.font.sm
                                font.bold: recentRow.index === root.historyIndex
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                                width: parent.width - Theme.spacing.md
                            }

                            MouseArea {
                                id: recentMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: root.historyIndex = recentRow.index
                                onClicked: root._run(recentRow.modelData)
                            }
                        }
                    }

                    LauncherEmptyState {
                        visible: root.launcher.state.recentCommands.length === 0
                        title: "No commands yet"
                        subtitle: "Run something and it'll show up here for quick reuse."
                    }
                }
            }

            // Live output (shown once a command has been run)
            ColumnLayout {
                anchors.fill: parent
                visible: root.hasRun
                spacing: Theme.spacing.xs

                Text {
                    Layout.fillWidth: true
                    text: "$ " + root.runCommand
                    font.family: "monospace"
                    font.pixelSize: Theme.font.sm
                    font.bold: true
                    color: Theme.textPrimary
                    elide: Text.ElideRight
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                ListView {
                    id: outputList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.outputLines
                    boundsBehavior: Flickable.StopAtBounds

                    onCountChanged: if (!root.userScrolled) outputList.positionViewAtEnd()

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onWheel: wheel => {
                            root.userScrolled = !outputList.atYEnd;
                            wheel.accepted = false;
                        }
                    }

                    delegate: Text {
                        width: outputList.width
                        text: modelData
                        wrapMode: Text.Wrap
                        font.family: "monospace"
                        font.pixelSize: Theme.font.sm
                        color: Theme.textSecondary
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: root.status === "running" ? Theme.textTertiary
                             : root.status === "success" ? Theme.textPrimary
                             : root.status === "failure" ? Theme.emphasis : "transparent"
                    }
                    Text {
                        text: root.status === "running" ? "running…"
                            : root.status === "success" ? "exited successfully (0)"
                            : root.status === "failure" ? "exited with code " + root.exitCode
                            : ""
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: Theme.textTertiary
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "Copy output"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: copyMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
                        MouseArea { id: copyMa; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._copyOutput() }
                    }
                    Text {
                        text: "Clear"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: clearMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
                        MouseArea { id: clearMa; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._clearOutput() }
                    }
                }
            }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: root.hasRun
                ? [ { key: "Ctrl+↵", label: "Terminal" }, { key: "↑↓", label: "History" }, { key: "Tab", label: "Modes" }, { key: "Esc", label: "Close" } ]
                : [ { key: "↵", label: "Run" }, { key: "Ctrl+↵", label: "Terminal" }, { key: "↑↓", label: "History" }, { key: "Esc", label: "Close" } ]
        }
    }
}
