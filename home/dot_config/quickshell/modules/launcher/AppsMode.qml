import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../../theme"
import "Search.mjs" as Search

// App Launcher: Spotlight-style search over DesktopEntries (see Search.js):
// typo-tolerant, multi-word, best-alignment fuzzy matching over name >
// command > generic name/keywords > categories, plus two learned boosts
// persisted by Launcher.qml - frecency (decayed launch count, so apps you
// stopped using fade) and query associations (what you picked after typing
// this exact prefix before, so "f" learns to mean Firefox). Favorites
// (launcher.state.favoriteApps) get a small fixed boost.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 520
    property int selectedIndex: 0

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    // [{ entry, positions }] - positions are the matched characters of
    // the name, for highlighting.
    readonly property var _ranked: {
        const q = searchBar.text.trim();
        const state = root.launcher.state;
        const usage = state.appUsage || {};
        const assoc = state.queryAssoc || {};
        const now = Date.now();
        const tokens = Search.tokenize(q);
        const seen = {};

        const scored = [];
        const all = DesktopEntries.applications.values;
        for (let i = 0; i < all.length; i++) {
            const e = all[i];
            if (!e || e.noDisplay || !e.id || seen[e.id]) continue;
            seen[e.id] = true;

            const name = e.name || "";
            let score = 0;
            let positions = [];
            if (tokens.length > 0) {
                const cmd = e.command && e.command.length > 0 ? e.command[0].split("/").pop() : "";
                // Reverse-DNS ids ("dev.zed.Delta") are vendor noise apart
                // from the last segment.
                const idTail = e.id.split(".").pop();
                const m = Search.match([
                    { text: name, weight: 1 },
                    { text: cmd + " " + idTail, weight: 0.8 },
                    { text: (e.genericName || "") + " " + (e.keywords || []).join(" "), weight: 0.55 },
                    { text: (e.categories || []).join(" "), weight: 0.25 }
                ], tokens);
                if (!m) continue;
                score = m.score + Search.assocBoost(assoc, q, e.id, now);
                positions = m.positions;
            }
            score += Search.frecencyBoost(usage[e.id], now);
            if (root.launcher.isFavoriteApp(e.id)) score += 10;

            scored.push({ entry: e, positions: positions, score: score, name: name });
        }

        scored.sort((a, b) => b.score - a.score || a.name.length - b.name.length || a.name.localeCompare(b.name));
        // Drop the long tail of weak matches once something clearly fits.
        if (tokens.length > 0 && scored.length > 0) {
            const cutoff = Math.max(25, scored[0].score * 0.3);
            return scored.filter(s => s.score >= cutoff);
        }
        return scored;
    }
    readonly property var filtered: root._ranked.map(r => r.entry)
    readonly property var _positions: {
        const out = {};
        for (let i = 0; i < root._ranked.length; i++) out[root._ranked[i].entry.id] = root._ranked[i].positions;
        return out;
    }
    onFilteredChanged: root.selectedIndex = 0

    function _launch(entry) {
        if (!entry) return;
        entry.execute();
        root.launcher.recordAppUsage(entry.id, searchBar.text);
        root.launcher.close();
    }
    function _launchInTerminal(entry) {
        if (!entry) return;
        terminalProc.command = ["ghostty", "-e", "bash", "-lc", entry.execString + "; exec bash"];
        terminalProc.running = true;
        root.launcher.recordAppUsage(entry.id, searchBar.text);
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
                                text: Search.highlight(row.modelData.name || "", root._positions[row.modelData.id], Theme.emphasis)
                                textFormat: Text.StyledText
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
                        onPositionChanged: mouse => { if (root.launcher.pointerMoved(row, mouse)) root.selectedIndex = row.index; }
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
