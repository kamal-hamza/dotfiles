import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"
import "../common"
import "../services"

// Music: Now Playing view reuses MediaService (native MPRIS, already
// bridging MPD via mpd-mpris - same singleton bar/NowPlayingPopup.qml
// uses) as-is, no new MPRIS code. Library search/queue is MPD-specific
// (generic MPRIS has no browsable library) and shells out to the same
// `mpc` this machine's existing keybinds/scripts already use - repeat/
// shuffle/smart-next reuse those exact scripts rather than re-parsing
// `mpc status` flags a second way.
Item {
    id: root

    required property var launcher
    readonly property int preferredHeight: 560

    function focusInput() { searchBar.focusInput(); }
    function clearQuery() { searchBar.text = ""; }

    readonly property bool searching: searchBar.text.trim() !== ""
    property bool showQueue: false
    property int selectedIndex: 0

    readonly property real progress: MediaService.length > 0
        ? Math.max(0, Math.min(1, MediaService.position / MediaService.length)) : 0

    Timer {
        interval: 250
        repeat: true
        running: root.visible && MediaService.isPlaying
        onTriggered: MediaService.tickProgress()
    }

    // --- Search (MPD library, via mpc) - songs only, no artist/album grouping ---
    property var songResults: []
    onSongResultsChanged: root.selectedIndex = 0
    onShowQueueChanged: {
        root.selectedIndex = 0;
        if (root.showQueue) root._refreshQueue();
    }

    // Telescope.nvim-style preview: whichever song is highlighted in the
    // results list, with its album art fetched on demand and cached to a
    // per-file temp path so re-highlighting the same song doesn't re-fetch
    // it. `mpc albumart` only finds an external cover.jpg/folder.jpg next
    // to the file; most of this library embeds art in the file's own tags
    // instead, which needs `mpc readpicture` - try both, external art first.
    readonly property var previewSong: (root.searching && root.songResults.length > 0)
        ? (root.songResults[root.selectedIndex] || null) : null
    property string previewArtPath: ""

    function _artPath(file) {
        return "/tmp/qs-music-art-" + file.replace(/[^a-zA-Z0-9_-]/g, "_").slice(-120) + ".bin";
    }

    Process {
        id: artProc
        property string pendingPath: ""
        onExited: code => { root.previewArtPath = code === 0 ? artProc.pendingPath : ""; }
    }
    onPreviewSongChanged: {
        if (!root.previewSong) { root.previewArtPath = ""; return; }
        const path = root._artPath(root.previewSong.file);
        artProc.pendingPath = path;
        artProc.command = ["sh", "-c",
            '[ -s "$1" ] || { mpc albumart "$0" > "$1" 2>/dev/null || mpc readpicture "$0" > "$1" 2>/dev/null; }; [ -s "$1" ]',
            root.previewSong.file, path];
        artProc.running = true;
    }

    Timer {
        id: searchDebounce
        interval: 200
        onTriggered: root._search()
    }
    Connections {
        target: searchBar.input
        function onTextChanged() { searchDebounce.restart(); }
    }

    Process {
        id: searchProc
        stdout: StdioCollector {
            id: searchCollector
            onStreamFinished: {
                const lines = searchCollector.text.split("\n").filter(l => l.trim() !== "");
                root.songResults = lines.map(l => {
                    const p = l.split("\t");
                    return { file: p[0] || "", artist: p[1] || "", title: p[2] || "", album: p[3] || "", time: p[4] || "" };
                });
            }
        }
    }
    function _search() {
        const q = searchBar.text.trim();
        if (q === "") { root.songResults = []; return; }
        searchProc.command = ["mpc", "-f", "%file%\t%artist%\t%title%\t%album%\t%time%", "search", "any", q];
        searchProc.running = true;
    }

    Process { id: insertProc; onExited: playProc.running = true }
    Process { id: playProc; command: ["mpc", "play"] }
    function _queueAndPlay(file) {
        if (!file) return;
        insertProc.command = ["mpc", "insert", file];
        insertProc.running = true;
    }

    // --- Queue ---
    property var queueEntries: []
    Process {
        id: queueProc
        command: ["mpc", "-f", "%position%\t%artist% - %title%", "playlist"]
        stdout: StdioCollector {
            id: queueCollector
            onStreamFinished: {
                const lines = queueCollector.text.split("\n").filter(l => l.trim() !== "");
                root.queueEntries = lines.map(l => {
                    const tab = l.indexOf("\t");
                    return { position: tab >= 0 ? l.slice(0, tab) : "", label: tab >= 0 ? l.slice(tab + 1) : l };
                });
            }
        }
    }
    function _refreshQueue() { queueProc.running = true; }
    onVisibleChanged: if (root.visible && root.showQueue) root._refreshQueue()

    Process { id: playPositionProc }
    function _playQueueEntry(entry) {
        if (!entry) return;
        playPositionProc.command = ["mpc", "play", entry.position];
        playPositionProc.running = true;
    }

    // --- Transport (reuses the exact scripts keymaps.lua already binds) ---
    Process { id: repeatProc; command: ["cycle-repeat-mode"] }
    Process { id: shuffleProc; command: ["toggle-shuffle"] }
    Process { id: smartNextProc; command: ["smart-next"] }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.md

        LauncherSearchBar {
            id: searchBar
            Layout.fillWidth: true
            glyph: "♪"
            modeLabel: "Music"
            placeholder: "Search songs, artists, albums..."
            countText: root.searching ? (root.songResults.length + " songs") : ""

            input.Keys.onPressed: event => {
                if (root.launcher.handleGlobalKeys(event)) { event.accepted = true; return; }
                const navigable = root.searching || root.showQueue;
                const navLength = root.searching ? root.songResults.length : root.queueEntries.length;
                if (event.key === Qt.Key_Space && !root.searching) {
                    MediaService.togglePlay();
                    event.accepted = true;
                } else if (!root.searching && (event.modifiers & Qt.ShiftModifier) && event.key === Qt.Key_Left) {
                    MediaService.previous();
                    event.accepted = true;
                } else if (!root.searching && (event.modifiers & Qt.ShiftModifier) && event.key === Qt.Key_Right) {
                    smartNextProc.running = true;
                    event.accepted = true;
                } else if (navigable && root.launcher.isNext(event)) {
                    root.selectedIndex = Math.min(root.selectedIndex + 1, navLength - 1);
                    event.accepted = true;
                } else if (navigable && root.launcher.isPrevious(event)) {
                    root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (root.searching) {
                        const s = root.songResults[root.selectedIndex];
                        if (s) root._queueAndPlay(s.file);
                    } else if (root.showQueue) {
                        root._playQueueEntry(root.queueEntries[root.selectedIndex]);
                    }
                    event.accepted = true;
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // --- Search results: song list + telescope.nvim-style preview ---
            RowLayout {
                anchors.fill: parent
                visible: root.searching
                spacing: Theme.spacing.md

                Item {
                    Layout.preferredWidth: parent.width * 0.42
                    Layout.fillHeight: true

                    ListView {
                        id: songList
                        anchors.fill: parent
                        clip: true
                        spacing: 2
                        model: root.songResults
                        currentIndex: root.selectedIndex

                        delegate: Rectangle {
                            id: songRow
                            required property var modelData
                            required property int index
                            width: ListView.view.width
                            height: 36
                            radius: Theme.radius.control
                            color: index === root.selectedIndex ? Theme.bgHover : "transparent"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: Theme.spacing.sm
                                anchors.rightMargin: Theme.spacing.sm
                                text: songRow.modelData.title || songRow.modelData.file
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.sm
                                font.bold: songRow.index === root.selectedIndex
                                color: Theme.textPrimary
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: root.selectedIndex = songRow.index
                                onClicked: root._queueAndPlay(songRow.modelData.file)
                            }
                        }
                    }

                    LauncherEmptyState {
                        visible: root.songResults.length === 0
                        title: "No songs found"
                        subtitle: "Searches your local MPD library by title, artist, and album."
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.previewSong !== null
                    radius: Theme.radius.control
                    color: Theme.bgControl
                    border.width: 1
                    border.color: Theme.border

                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.spacing.md
                        spacing: Theme.spacing.sm

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 128
                            height: 128
                            radius: Theme.radius.control
                            color: Theme.bgElevated
                            clip: true

                            Image {
                                id: previewArt
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: status === Image.Ready
                                source: root.previewArtPath ? "file://" + root.previewArtPath : ""
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: previewArt.status !== Image.Ready
                                text: "󰎈"
                                font.family: Theme.fontFamily
                                font.pixelSize: 40
                                color: Theme.textTertiary
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            text: root.previewSong ? (root.previewSong.title || root.previewSong.file) : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.md
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            visible: text.length > 0
                            text: root.previewSong ? root.previewSong.artist : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.sm
                            color: Theme.textSecondary
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            visible: text.length > 0
                            text: root.previewSong ? root.previewSong.album : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.sm
                            color: Theme.textTertiary
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            visible: text.length > 0
                            text: root.previewSong ? root.previewSong.time : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            color: Theme.textTertiary
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.border }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            visible: text.length > 0
                            text: root.previewSong ? root.previewSong.file : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            color: Theme.textTertiary
                        }
                    }
                }
            }

            // --- Queue ---
            ColumnLayout {
                anchors.fill: parent
                visible: !root.searching && root.showQueue
                spacing: Theme.spacing.sm

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                ListView {
                    id: queueList
                    anchors.fill: parent
                    clip: true
                    spacing: 2
                    model: root.queueEntries
                    currentIndex: root.selectedIndex

                    delegate: Rectangle {
                        id: queueRow
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: 32
                        radius: Theme.radius.control
                        readonly property bool current: modelData.label.indexOf(MediaService.trackTitle) >= 0 && MediaService.hasPlayer
                        color: queueRow.index === root.selectedIndex ? Theme.bgHover : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacing.sm
                            anchors.rightMargin: Theme.spacing.sm
                            Text {
                                text: queueRow.current ? "▶" : ""
                                color: Theme.textPrimary
                                font.pixelSize: Theme.font.xs
                            }
                            Text {
                                Layout.fillWidth: true
                                text: queueRow.modelData.label
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.font.sm
                                font.bold: queueRow.current
                                color: Theme.textPrimary
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.selectedIndex = queueRow.index
                            onClicked: root._playQueueEntry(queueRow.modelData)
                        }
                    }
                }

                LauncherEmptyState {
                    visible: root.queueEntries.length === 0
                    title: "Queue is empty"
                    subtitle: "Search for a song to add it to the queue."
                }
                }
            }

            // --- Now Playing ---
            ColumnLayout {
                anchors.fill: parent
                visible: !root.searching && !root.showQueue
                spacing: Theme.spacing.md

                Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 180
                    height: 180
                    radius: Theme.radius.card
                    color: Theme.bgControl
                    clip: true

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                        source: MediaService.cachedArtUrl
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: MediaService.cachedArtUrl === ""
                        text: "󰎈"
                        font.family: Theme.fontFamily
                        font.pixelSize: 56
                        color: Theme.textTertiary
                    }
                }

                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: MediaService.hasPlayer ? MediaService.trackTitle : "Nothing playing"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.lg
                        font.bold: true
                        color: Theme.textPrimary
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: MediaService.trackArtist.length > 0
                        text: MediaService.trackArtist + (MediaService.trackAlbum ? " — " + MediaService.trackAlbum : "")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.sm
                        color: Theme.textTertiary
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Theme.spacing.xs
                    visible: MediaService.hasPlayer

                    Slider {
                        width: parent.width
                        value: root.progress
                        draggable: MediaService.canSeek
                        onMoved: v => MediaService.seek(v * MediaService.length)
                    }
                    Item {
                        width: parent.width
                        height: 14
                        Text {
                            anchors.left: parent.left
                            text: MediaService.formatTime(MediaService.position)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            color: Theme.textTertiary
                        }
                        Text {
                            anchors.right: parent.right
                            text: MediaService.formatTime(MediaService.length)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.font.xs
                            color: Theme.textTertiary
                        }
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacing.md

                    component TransportButton: Rectangle {
                        id: btn
                        property string glyph: ""
                        property bool primary: false
                        signal clicked()
                        width: primary ? 46 : 34
                        height: width
                        radius: width / 2
                        color: primary ? Theme.emphasis : (btnMa.containsMouse ? Theme.bgHover : "transparent")
                        border.width: primary ? 0 : 1
                        border.color: Theme.border
                        opacity: btn.enabled ? 1 : 0.35
                        Text {
                            anchors.centerIn: parent
                            text: btn.glyph
                            font.family: Theme.fontFamily
                            font.pixelSize: btn.primary ? Theme.font.lg : Theme.font.md
                            color: btn.primary ? Theme.textOnEmphasis : Theme.textPrimary
                        }
                        MouseArea {
                            id: btnMa
                            anchors.fill: parent
                            enabled: btn.enabled
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btn.clicked()
                        }
                    }

                    TransportButton { glyph: "󰒮"; enabled: MediaService.canGoPrevious; onClicked: MediaService.previous() }
                    TransportButton { primary: true; glyph: MediaService.isPlaying ? "󰏤" : "󰐊"; enabled: MediaService.canTogglePlaying; onClicked: MediaService.togglePlay() }
                    TransportButton { glyph: "󰒭"; enabled: MediaService.canGoNext; onClicked: smartNextProc.running = true }
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Repeat"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: repeatMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
                        MouseArea { id: repeatMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: repeatProc.running = true }
                    }
                    Text {
                        text: "Shuffle"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: shuffleMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
                        MouseArea { id: shuffleMa; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: shuffleProc.running = true }
                    }
                    Text {
                        text: "Queue"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.font.xs
                        color: root.showQueue ? Theme.textPrimary : Theme.textTertiary
                        MouseArea { anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.showQueue = true }
                    }
                }

                Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.showQueue && !root.searching
            text: "← Back to Now Playing"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.font.xs
            color: backMa.containsMouse ? Theme.textPrimary : Theme.textTertiary
            MouseArea { id: backMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.showQueue = false }
        }

        LauncherFooter {
            Layout.fillWidth: true
            hints: root.searching
                ? [ { key: "↵", label: "Play first result" }, { key: "Tab", label: "Modes" }, { key: "Esc", label: "Close" } ]
                : [ { key: "Space", label: "Play/Pause" }, { key: "Shift+←/→", label: "Prev/Next" }, { key: "Tab", label: "Modes" }, { key: "Esc", label: "Close" } ]
        }
    }
}
