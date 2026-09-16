import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../../theme"
import "Fuzzy.js" as Fuzzy

// App Launcher: fuzzy search over DesktopEntries with a frecency boost
// (usage count + recency, tracked in launcher.state.appUsage) and favorites
// (launcher.state.favoriteApps) - both persisted by Launcher.qml.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 520
    property int selectedIndex: 0

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    property var filtered: {
        const q = searchBar.text.trim();
        const usage = root.launcher.state.appUsage || {};
        const seen = {};
        const all = DesktopEntries.applications.values.filter(e => {
            if (!e || e.noDisplay || !e.id || seen[e.id]) return false;
            seen[e.id] = true;
            return true;
        });

        const scored = [];
        for (let i = 0; i < all.length; i++) {
            const e = all[i];
            const metadata = [e.genericName || "", (e.keywords || []).join(" "), (e.categories || []).join(" ")].join(" ");

            // Fuzzy match name first; a metadata-only match still counts
            // but ranks below any real name match.
            let score = Fuzzy.score(e.name || "", q);
            if (score < 0) {
                score = Fuzzy.score(metadata, q);
                if (score >= 0) score *= 0.3;
            }
            if (score < 0) continue;

            const u = usage[e.id];
            if (u) {
                score += Math.min(u.count, 20) * 2;
                if (Date.now() - u.lastUsed < 1000 * 60 * 60 * 24 * 7) score += 10;
            }
            if (root.launcher.isFavoriteApp(e.id)) score += 15;

            scored.push({ entry: e, score: score, name: e.name || "" });
        }

        scored.sort((a, b) => b.score - a.score || a.name.localeCompare(b.name));
        return scored.map(s => s.entry);
    }
    onFilteredChanged: root.selectedIndex = 0

    function _launch(entry) {
        if (!entry) return;
        entry.execute();
        root.launcher.recordAppUsage(entry.id);
        root.launcher.close();
    }
    function _launchInTerminal(entry) {
        if (!entry) return;
        terminalProc.command = ["ghostty", "-e", "bash", "-lc", entry.execString + "; exec bash"];
        terminalProc.running = true;
        root.launcher.recordAppUsage(entry.id);
        root.launcher.close();
    }
    function _openDesktopFile(entry) {
        if (!entry) return;
        openFileProc.command = ["sh", "-c",
            'f="$HOME/.local/share/applications/$0.desktop"; [ -f "$f" ] || f="/usr/share/applications/$0.desktop"; xdg-open "$f"',
            entry.id];
        openFileProc.running = true;
    }

    Process { id: terminalProc }
    Process { id: openFileProc }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "◉"
            modeLabel: "Apps"
            placeholder: "Search applications..."
            countText: root.filtered.length + (root.filtered.length === 1 ? " app" : " apps")

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
                    root._launch(root.filtered[root.selectedIndex]);
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
                    width: list.width
                    height: 52
                    radius: Theme.radius.control
                    color: index === root.selectedIndex ? Theme.bgHover : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.motion.fast } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.sm
                        anchors.rightMargin: Theme.spacing.sm
                        spacing: Theme.spacing.md

                        Item {
                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            IconImage {
                                id: iconImg
                                anchors.fill: parent
                                source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : ""
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: iconImg.source === ""
                                text: "󰀻"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.lg
                                color: Theme.textTertiary
                            }
                        }

                        Column {
                            width: parent.width - 32 - favGlyph.width - Theme.spacing.md * 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                width: parent.width
                                text: row.modelData.name || ""
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.md
                                font.bold: row.index === root.selectedIndex
                                color: Theme.textPrimary
                            }
                            Text {
                                width: parent.width
                                visible: text.length > 0
                                text: row.modelData.genericName || row.modelData.comment || ""
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.xs
                                color: Theme.textTertiary
                            }
                        }

                        Text {
                            id: favGlyph
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.launcher.isFavoriteApp(row.modelData.id)
                            width: visible ? implicitWidth : 0
                            text: "★"
                            font.pixelSize: Theme.font.sm
                            color: Theme.textTertiary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: root.selectedIndex = row.index
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.entry = row.modelData;
                                contextMenu.popup();
                            } else {
                                root._launch(row.modelData);
                            }
                        }
                    }
                }
            }

            LauncherEmptyState {
                visible: root.filtered.length === 0
                title: "No applications found"
                subtitle: "Try searching by application name, keyword, or category."
            }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: [
                { key: "↑↓", label: "Navigate" },
                { key: "↵", label: "Launch" },
                { key: "Tab", label: "Modes" },
                { key: "Esc", label: "Close" }
            ]
        }
    }

    Menu {
        id: contextMenu
        property var entry: null

        MenuItem {
            text: "Launch"
            onTriggered: root._launch(contextMenu.entry)
        }
        MenuItem {
            text: "Launch in terminal"
            onTriggered: root._launchInTerminal(contextMenu.entry)
        }
        MenuItem {
            text: contextMenu.entry && root.launcher.isFavoriteApp(contextMenu.entry.id) ? "Remove from favorites" : "Add to favorites"
            onTriggered: root.launcher.toggleFavoriteApp(contextMenu.entry.id)
        }
        MenuItem {
            text: "Open desktop file"
            onTriggered: root._openDesktopFile(contextMenu.entry)
        }
    }
}
