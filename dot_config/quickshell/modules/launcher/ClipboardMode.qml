import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"
import "Fuzzy.js" as Fuzzy

// Clipboard History: backed by `cliphist` (needs the wl-paste watchers set
// up in hypr/conf/execs.lua to actually populate). `cliphist list` prints
// "<id>\t<preview>" per line; binary/image entries render their preview as
// "binary data ..." - detected heuristically since cliphist has no
// machine-readable list format.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 520
    property int selectedIndex: 0

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    property var rawEntries: []

    property var filtered: {
        const q = searchBar.text.trim();
        if (q === "") return root.rawEntries;
        return root.rawEntries
            .map(e => ({ entry: e, score: Fuzzy.score(e.preview, q) }))
            .filter(s => s.score >= 0)
            .sort((a, b) => b.score - a.score)
            .map(s => s.entry);
    }
    onFilteredChanged: root.selectedIndex = 0
    onVisibleChanged: if (root.visible) root._refresh()

    function _isImageLine(preview) {
        return /binary data/i.test(preview) || /image\//i.test(preview);
    }
    function _thumbPath(id) {
        return "/tmp/qs-clip-" + id.replace(/[^a-zA-Z0-9_-]/g, "_") + ".bin";
    }

    function _refresh() {
        listProc.running = true;
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            id: listCollector
            onStreamFinished: {
                const lines = listCollector.text.split("\n").filter(l => l.trim() !== "");
                root.rawEntries = lines.map(line => {
                    const tab = line.indexOf("\t");
                    const id = tab >= 0 ? line.slice(0, tab) : line;
                    const preview = tab >= 0 ? line.slice(tab + 1) : "";
                    return { id: id, preview: preview, line: line, isImage: root._isImageLine(preview) };
                });
            }
        }
    }
    Process { id: copyProc }
    Process { id: deleteProc; onExited: root._refresh() }
    Process { id: wipeProc; command: ["cliphist", "wipe"]; onExited: root._refresh() }

    function _copy(entry) {
        if (!entry) return;
        copyProc.command = ["sh", "-c", 'cliphist decode "$0" | wl-copy', entry.id];
        copyProc.running = true;
        root.launcher.close();
    }
    function _delete(entry) {
        if (!entry) return;
        deleteProc.command = ["sh", "-c", 'printf "%s" "$0" | cliphist delete', entry.line];
        deleteProc.running = true;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "⧉"
            modeLabel: "Clipboard"
            placeholder: "Search clipboard history..."
            countText: root.filtered.length + (root.filtered.length === 1 ? " entry" : " entries")

            input.Keys.onPressed: event => {
                if (root.launcher.handleGlobalKeys(event)) { event.accepted = true; return; }
                if (root.launcher.isNext(event)) {
                    root.selectedIndex = Math.min(root.selectedIndex + 1, root.filtered.length - 1);
                    list.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                    event.accepted = true;
                } else if (root.launcher.isPrevious(event)) {
                    root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                    list.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root._copy(root.filtered[root.selectedIndex]);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ControlModifier)) {
                    root._delete(root.filtered[root.selectedIndex]);
                    event.accepted = true;
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 4
                model: root.filtered
                currentIndex: root.selectedIndex
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: index === root.selectedIndex

                    width: list.width
                    height: selected ? 92 : 56
                    radius: Theme.radius.control
                    color: selected ? Theme.bgHover : "transparent"
                    clip: true

                    Behavior on height { NumberAnimation { duration: Theme.motion.fast } }
                    Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                    Process {
                        id: decodeProc
                        onExited: thumb.source = "file://" + root._thumbPath(row.modelData.id)
                    }
                    Component.onCompleted: {
                        if (row.modelData.isImage) {
                            decodeProc.command = ["sh", "-c",
                                '[ -f "$1" ] || cliphist decode "$0" > "$1"',
                                row.modelData.id, root._thumbPath(row.modelData.id)];
                            decodeProc.running = true;
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacing.sm
                        spacing: Theme.spacing.md

                        Rectangle {
                            visible: row.modelData.isImage
                            Layout.preferredWidth: row.selected ? 76 : 44
                            Layout.preferredHeight: row.selected ? 76 : 44
                            Layout.alignment: Qt.AlignVCenter
                            radius: Theme.radius.control
                            color: Theme.bgControl
                            clip: true

                            Image {
                                id: thumb
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                visible: row.modelData.isImage
                                text: "Image"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.sm
                                font.bold: true
                                color: Theme.textPrimary
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: row.modelData.isImage
                                text: thumb.status === Image.Ready ? (thumb.sourceSize.width + " × " + thumb.sourceSize.height) : "Loading…"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.xs
                                color: Theme.textTertiary
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: !row.modelData.isImage
                                text: row.modelData.preview
                                font.family: "monospace"
                                font.pixelSize: Theme.font.sm
                                color: Theme.textPrimary
                                elide: Text.ElideRight
                                maximumLineCount: row.selected ? 4 : 1
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: root.selectedIndex = row.index
                        onClicked: root._copy(row.modelData)
                    }
                }
            }

            LauncherEmptyState {
                visible: root.filtered.length === 0
                title: root.rawEntries.length === 0 ? "No clipboard entries" : "No matches"
                subtitle: root.rawEntries.length === 0 ? "Copy something and it will appear here." : "Try a different search term."
            }

            Text {
                anchors.top: parent.top
                anchors.right: parent.right
                visible: root.rawEntries.length > 0
                text: "Clear all"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                color: wipeMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
                MouseArea { id: wipeMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wipeProc.running = true }
            }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: [
                { key: "↑↓", label: "Navigate" },
                { key: "↵", label: "Copy" },
                { key: "Ctrl+Del", label: "Delete" },
                { key: "Tab", label: "Modes" },
                { key: "Esc", label: "Close" }
            ]
        }
    }
}
