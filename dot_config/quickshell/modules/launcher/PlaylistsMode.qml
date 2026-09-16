import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

// Playlists: browse and play whole top-level MPD library folders (e.g.
// ~/Music/<Album>) - the equivalent of rofi's old play-playlist script,
// reachable via SUPER+SHIFT+GRAVE. Kept as its own launcher mode, separate
// from Music's individual-song search/queue.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 460
    property int selectedIndex: 0

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    property var allPlaylists: []
    property var filtered: {
        const q = searchBar.text.trim().toLowerCase();
        if (q === "") return root.allPlaylists;
        return root.allPlaylists.filter(p => p.name.toLowerCase().includes(q));
    }
    onFilteredChanged: root.selectedIndex = 0
    onVisibleChanged: if (root.visible) root._refresh()

    function _formatDuration(totalSeconds) {
        const h = Math.floor(totalSeconds / 3600);
        const m = Math.floor((totalSeconds % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }

    // One line per top-level folder: "<name>\t<song count>\t<total seconds>".
    // Per-song times come from `mpc listall` (not `lsdirs`, which only gives
    // names) - cheap enough for a handful of top-level playlist folders.
    Process {
        id: listProc
        command: ["sh", "-c", `
            mpc lsdirs | while IFS= read -r dir; do
                [ "$dir" = "Lyrics" ] && continue
                times=$(mpc -f "%time%" listall "$dir")
                count=$(printf '%s\\n' "$times" | grep -c .)
                total=$(printf '%s\\n' "$times" | awk -F: '{ if (NF==2) s+=$1*60+$2; else if (NF==3) s+=$1*3600+$2*60+$3 } END { print s+0 }')
                printf '%s\\t%s\\t%s\\n' "$dir" "$count" "$total"
            done
        `]
        stdout: StdioCollector {
            id: listCollector
            onStreamFinished: {
                root.allPlaylists = listCollector.text.split("\n")
                    .filter(l => l.trim() !== "")
                    .map(l => {
                        const p = l.split("\t");
                        return { name: p[0] || "", count: parseInt(p[1] || "0", 10), totalSeconds: parseInt(p[2] || "0", 10) };
                    });
            }
        }
    }
    function _refresh() { listProc.running = true; }

    // Whether playback ends up shuffled follows whatever MPD's random mode
    // is currently set to (SUPER+S / Shuffle link elsewhere toggles it).
    Process { id: clearProc; onExited: addProc.running = true }
    Process { id: addProc; onExited: playProc.running = true }
    Process { id: playProc; command: ["mpc", "play"] }
    function _play(entry) {
        if (!entry) return;
        addProc.command = ["mpc", "add", entry.name];
        clearProc.command = ["mpc", "clear"];
        clearProc.running = true;
        root.launcher.close();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "▶"
            modeLabel: "Playlists"
            placeholder: "Search playlists..."
            countText: root.filtered.length + (root.filtered.length === 1 ? " playlist" : " playlists")

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
                    root._play(root.filtered[root.selectedIndex]);
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
                spacing: 2
                model: root.filtered
                currentIndex: root.selectedIndex
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 52
                    radius: Theme.radius.control
                    color: index === root.selectedIndex ? Theme.bgHover : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.spacing.sm
                        anchors.rightMargin: Theme.spacing.sm
                        spacing: 1

                        Text {
                            width: parent.width
                            text: row.modelData.name
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.sm
                            font.bold: row.index === root.selectedIndex
                            color: Theme.textPrimary
                        }
                        Text {
                            width: parent.width
                            text: row.modelData.count + (row.modelData.count === 1 ? " song" : " songs")
                                + " · " + root._formatDuration(row.modelData.totalSeconds)
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            color: Theme.textTertiary
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: root.selectedIndex = row.index
                        onClicked: root._play(row.modelData)
                    }
                }
            }

            LauncherEmptyState {
                visible: root.filtered.length === 0
                title: "No playlists found"
                subtitle: "Top-level folders in your MPD library show up here."
            }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: [
                { key: "↑↓", label: "Navigate" },
                { key: "↵", label: "Play" },
                { key: "Tab", label: "Modes" },
                { key: "Esc", label: "Close" }
            ]
        }
    }
}
