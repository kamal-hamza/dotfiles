import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

// Library: three Tab-switchable views onto your music - Artists, Albums,
// and Playlists - so Tab (freed up from cycling launcher modes; every mode
// has its own direct keybind anyway, see keymaps.lua) means "switch view"
// consistently within this mode instead of leaving the launcher entirely.
//
// Artists/Albums browse via `music-library` (dot_local/bin, backed by
// beets' own library.db) rather than raw `mpc list`, for two reasons: (1)
// it replaces folder-browsing, which assumed "one top-level ~/Music folder
// = one playable collection" - broken once the library moved to beets'
// $albumartist/$album layout; (2) `mpc list albumartist` lists each collab
// credit string as its own entry ("Arijit Singh", "Arijit Singh; Amaal
// Mallik", ... as separate rows), so picking one artist could never pull in
// every track they're a collaborator on - `music-library` reads beets'
// parsed per-track artist list instead, so an artist shows up once with
// every track they're credited on, solo or collab.
//
// Playlists is different in kind - MPD's own saved playlists (`mpc save`/
// `mpc load`, .m3u under mpd.conf's playlist_directory), a user-curated,
// manually ordered set of tracks with no tag-based equivalent - so it goes
// straight through `mpc`, no `music-library` involved.
//
// Reachable via SUPER+SHIFT+GRAVE, same slot the old Playlists mode used.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 460
    property int selectedIndex: 0

    // Three top-level tabs, cycled with plain Tab: "artists" (drill into
    // one artist's albums), "albums" (flat, search every album directly -
    // no need to know/pick the artist first), "playlists" (MPD's saved
    // playlists, flat).
    readonly property var tabOrder: ["artists", "albums", "playlists"]
    property string tab: "playlists"
    property bool drilled: false   // tab === "artists" && drilled into selectedArtist
    property string selectedArtist: ""

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() {
        searchBar.text = "";
        root.drilled = false;
        root.selectedArtist = "";
    }

    property var allArtists: []
    property var artistAlbums: []   // albums for selectedArtist, "Play all" pinned first
    property var allAlbumsFlat: []  // every (album, albumartist) in the library
    property var allPlaylists: []   // MPD's saved playlists

    property var filtered: {
        const q = searchBar.text.trim().toLowerCase();
        let list;
        if (root.tab === "albums") list = root.allAlbumsFlat;
        else if (root.tab === "playlists") list = root.allPlaylists;
        else if (root.drilled) list = root.artistAlbums;
        else list = root.allArtists;
        if (q === "") return list;
        return list.filter(x => x.name.toLowerCase().includes(q) || (x.artist && x.artist.toLowerCase().includes(q)));
    }
    onFilteredChanged: root.selectedIndex = 0

    // `visible` above only reflects launcher.mode === "library", not whether
    // the launcher window itself is open - Launcher.qml intentionally keeps
    // every mode's Item alive and only flips `visible` on mode switch, so
    // typed queries survive a close/reopen. That means this component's own
    // visible can already be true going into a reopen (you closed while on
    // Library, then reopened straight into Library), and it never toggles
    // false->true again - so resetting only on that transition would leave
    // the tab wherever you last left it instead of defaulting fresh each
    // time. Watching launcher.visible directly catches that "reopened from
    // fully closed" case too.
    onVisibleChanged: if (root.visible) root._resetToDefault();
    Connections {
        target: root.launcher
        function onVisibleChanged() {
            if (root.launcher.visible && root.launcher.mode === "library") root._resetToDefault();
        }
    }
    function _resetToDefault() {
        root.tab = "playlists";
        root.drilled = false;
        root.selectedArtist = "";
        root._refreshArtists();
        root._refreshAllAlbums();
        root._refreshPlaylists();
    }
    function _switchTab(t) {
        if (root.tab === t) return;
        root.tab = t;
        root.drilled = false;
        root.selectedArtist = "";
        searchBar.text = "";
    }
    function _cycleTab() {
        const i = root.tabOrder.indexOf(root.tab);
        root._switchTab(root.tabOrder[(i + 1) % root.tabOrder.length]);
    }

    function _formatDuration(totalSeconds) {
        const h = Math.floor(totalSeconds / 3600);
        const m = Math.floor((totalSeconds % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }

    // --- Artists ---
    Process {
        id: artistsProc
        command: ["music-library", "artists"]
        stdout: StdioCollector {
            id: artistsCollector
            onStreamFinished: {
                root.allArtists = artistsCollector.text.split("\n")
                    .filter(l => l.trim() !== "")
                    .map(l => ({ name: l }));
            }
        }
    }
    function _refreshArtists() { artistsProc.running = true; }

    // --- Albums for the drilled-into artist, with count/duration per
    // album - already computed beets-side (musiclib.list_albums), so this
    // is one process call, not a per-album mpc round-trip.
    Process {
        id: albumsProc
        stdout: StdioCollector {
            id: albumsCollector
            onStreamFinished: {
                const albums = JSON.parse(albumsCollector.text || "[]");
                const totalCount = albums.reduce((s, a) => s + a.count, 0);
                const totalSeconds = albums.reduce((s, a) => s + a.totalSeconds, 0);
                root.artistAlbums = [{ name: "Play all", count: totalCount, totalSeconds: totalSeconds, playAll: true }].concat(albums);
            }
        }
    }
    function _refreshAlbums(artist) {
        albumsProc.command = ["music-library", "albums", artist];
        albumsProc.running = true;
    }

    // --- Flat album list (all artists), for the Albums tab ---
    Process {
        id: allAlbumsProc
        command: ["music-library", "all-albums"]
        stdout: StdioCollector {
            id: allAlbumsCollector
            onStreamFinished: {
                root.allAlbumsFlat = JSON.parse(allAlbumsCollector.text || "[]");
            }
        }
    }
    function _refreshAllAlbums() { allAlbumsProc.running = true; }

    // --- Playlists (MPD's own saved playlists, via `mpc`) ---
    Process {
        id: playlistsProc
        command: ["sh", "-c", `
            mpc lsplaylists | while IFS= read -r name; do
                times=$(mpc -f "%time%" playlist "$name")
                count=$(printf '%s\\n' "$times" | grep -c .)
                total=$(printf '%s\\n' "$times" | awk -F: '{ if (NF==2) s+=$1*60+$2; else if (NF==3) s+=$1*3600+$2*60+$3 } END { print s+0 }')
                printf '%s\\t%s\\t%s\\n' "$name" "$count" "$total"
            done
        `]
        stdout: StdioCollector {
            id: playlistsCollector
            onStreamFinished: {
                root.allPlaylists = playlistsCollector.text.split("\n")
                    .filter(l => l.trim() !== "")
                    .map(l => {
                        const p = l.split("\t");
                        return { name: p[0] || "", count: parseInt(p[1] || "0", 10), totalSeconds: parseInt(p[2] || "0", 10) };
                    });
            }
        }
    }
    function _refreshPlaylists() { playlistsProc.running = true; }

    function _open(entry) {
        if (root.tab === "artists" && !root.drilled) {
            root.selectedArtist = entry.name;
            root.drilled = true;
            searchBar.text = "";
            root._refreshAlbums(entry.name);
            return;
        }
        root._play(entry);
    }
    function _back() {
        root.drilled = false;
        root.selectedArtist = "";
        searchBar.text = "";
    }

    // Whether playback ends up shuffled follows whatever MPD's random mode
    // is currently set to (SUPER+S / Shuffle link elsewhere toggles it).
    //
    // Artists/Albums playback is driven by exact paths from `music-library
    // tracks`/`album-tracks`, not an MPD tag query - that's what makes
    // "Play all" for an artist pull in every collab track they're on
    // rather than just whichever ones share their exact ALBUMARTIST credit
    // string. Playlists playback just loads the saved .m3u via `mpc load`.
    // Both share the same clear -> (add|load) -> play tail, dispatched by
    // _playKind since which middle step runs depends on which was used.
    property string _playKind: ""
    Process {
        id: tracksProc
        stdout: StdioCollector {
            id: tracksCollector
            onStreamFinished: {
                const paths = tracksCollector.text.split("\n").filter(l => l.trim() !== "");
                if (paths.length === 0) return;
                addProc.command = ["mpc", "add"].concat(paths);
                clearProc.running = true;
            }
        }
    }
    Process { id: clearProc; command: ["mpc", "clear"]; onExited: (root._playKind === "playlist" ? loadProc : addProc).running = true }
    Process { id: addProc; onExited: playProc.running = true }
    Process { id: loadProc; onExited: playProc.running = true }
    Process { id: playProc; command: ["mpc", "play"] }
    function _play(entry) {
        if (!entry) return;
        if (root.tab === "playlists") {
            root._playKind = "playlist";
            loadProc.command = ["mpc", "load", entry.name];
            clearProc.running = true;
        } else {
            root._playKind = "tracks";
            tracksProc.command = root.tab === "albums"
                ? ["music-library", "album-tracks", entry.name, entry.artist]
                : (entry.playAll
                    ? ["music-library", "tracks", root.selectedArtist]
                    : ["music-library", "tracks", root.selectedArtist, entry.name]);
            tracksProc.running = true;
        }
        root.launcher.close();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "▤"
            modeLabel: "Library"
            placeholder: root.tab === "albums" ? "Search albums..."
                : root.tab === "playlists" ? "Search playlists..."
                : (root.drilled ? ("Search albums by " + root.selectedArtist + "...") : "Search artists...")
            countText: root.filtered.length + " " + (
                root.tab === "playlists" ? (root.filtered.length === 1 ? "playlist" : "playlists")
                : (root.tab === "albums" || root.drilled) ? (root.filtered.length === 1 ? "album" : "albums")
                : (root.filtered.length === 1 ? "artist" : "artists"))

            input.Keys.onPressed: event => {
                if (event.key === Qt.Key_Tab) {
                    root._cycleTab();
                    event.accepted = true;
                    return;
                }
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
                    root._open(root.filtered[root.selectedIndex]);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backspace && searchBar.text === "" && root.drilled) {
                    root._back();
                    event.accepted = true;
                }
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: Theme.spacing.lg

            Text {
                text: "Artists"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: root.tab === "artists"
                color: root.tab === "artists" ? Theme.textPrimary : (artistsTabMa.containsMouse ? Theme.textPrimary : Theme.textTertiary)
                MouseArea { id: artistsTabMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._switchTab("artists") }
            }
            Text {
                text: "Albums"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: root.tab === "albums"
                color: root.tab === "albums" ? Theme.textPrimary : (albumsTabMa.containsMouse ? Theme.textPrimary : Theme.textTertiary)
                MouseArea { id: albumsTabMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._switchTab("albums") }
            }
            Text {
                text: "Playlists"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.font.xs
                font.bold: root.tab === "playlists"
                color: root.tab === "playlists" ? Theme.textPrimary : (playlistsTabMa.containsMouse ? Theme.textPrimary : Theme.textTertiary)
                MouseArea { id: playlistsTabMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._switchTab("playlists") }
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
                            text: (row.modelData.playAll ? "▶ " : "") + row.modelData.name
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.sm
                            font.bold: row.index === root.selectedIndex || row.modelData.playAll
                            color: Theme.textPrimary
                        }
                        Text {
                            width: parent.width
                            visible: root.tab === "albums" || root.tab === "playlists" || root.drilled
                            text: (root.tab === "albums" ? (row.modelData.artist + " · ") : "")
                                + row.modelData.count + (row.modelData.count === 1 ? " song" : " songs")
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
                        onClicked: root._open(row.modelData)
                    }
                }
            }

            LauncherEmptyState {
                visible: root.filtered.length === 0
                title: root.tab === "albums" ? "No albums found"
                    : root.tab === "playlists" ? "No playlists found"
                    : (root.drilled ? "No albums found" : "No artists found")
                subtitle: root.tab === "albums" ? "Every album in your music library shows up here."
                    : root.tab === "playlists" ? "Playlists saved with `mpc save` show up here."
                    : (root.drilled ? (root.selectedArtist + " has no tagged albums.") : "Artists in your music library show up here.")
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.drilled
            text: "← Back to Artists"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            color: backMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
            MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root._back() }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: root.tab === "albums"
                ? [ { key: "↑↓", label: "Navigate" }, { key: "↵", label: "Play album" }, { key: "Tab", label: "Artists/Albums/Playlists" }, { key: "Esc", label: "Close" } ]
                : root.tab === "playlists"
                ? [ { key: "↑↓", label: "Navigate" }, { key: "↵", label: "Play" }, { key: "Tab", label: "Artists/Albums/Playlists" }, { key: "Esc", label: "Close" } ]
                : root.drilled
                ? [ { key: "↑↓", label: "Navigate" }, { key: "↵", label: "Play album" }, { key: "⌫", label: "Back" }, { key: "Tab", label: "Artists/Albums/Playlists" }, { key: "Esc", label: "Close" } ]
                : [ { key: "↑↓", label: "Navigate" }, { key: "↵", label: "Open artist" }, { key: "Tab", label: "Artists/Albums/Playlists" }, { key: "Esc", label: "Close" } ]
        }
    }
}
