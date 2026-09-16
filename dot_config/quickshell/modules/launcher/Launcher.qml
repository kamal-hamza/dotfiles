import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../theme"

// Rofi replacement: one PanelWindow shared by all seven launcher modes
// (Apps/Run/Calc/Clipboard/Music/Playlists/Power), toggled via `qs ipc call
// launcher <mode>` from Hyprland keybinds (see keymaps.lua). Each mode is a
// plain Item instantiated once and kept alive for the shell's lifetime -
// switching modes just flips `visible`, which is what lets every mode keep
// its own typed-in query across Tab-cycling for free (nothing is destroyed
// or recreated).
//
// This build of Quickshell (0.3.1) has no `Scope` type, so the window
// itself doubles as the non-visual container for the IpcHandler/FileView/
// Process below - the same pattern already used by PowerActions.qml, where
// Process children live directly under a plain Item.
PanelWindow {
    id: launcher

    visible: false
    focusable: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: launcher.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    property string mode: "apps"
    readonly property var modeOrder: ["apps", "run", "calc", "clipboard", "music", "playlists", "power"]

    function open(m) {
        launcher.mode = m;
        launcher.visible = true;
        focusTimer.restart();
    }
    function close() {
        launcher.visible = false;
        // Fresh state on next open - only the current session's typed
        // query is cleared, not persisted things like recent commands.
        for (const m of launcher.allModes) {
            if (m.clearQuery) m.clearQuery();
        }
    }
    function toggleVisible() {
        if (launcher.visible) launcher.close(); else launcher.open("apps");
    }
    function cycle() {
        const i = launcher.modeOrder.indexOf(launcher.mode);
        launcher.mode = launcher.modeOrder[(i + 1) % launcher.modeOrder.length];
        focusTimer.restart();
    }

    // Common Escape/Tab handling every mode's TextInput calls first, before
    // its own arrow/enter handling. Returns true if the event was consumed.
    function handleGlobalKeys(event) {
        if (event.key === Qt.Key_Escape) {
            launcher.close();
            return true;
        }
        if (event.key === Qt.Key_Tab) {
            launcher.cycle();
            return true;
        }
        return false;
    }

    // Every mode's next/previous nav accepts either the arrow keys or the
    // readline-style Ctrl+N/Ctrl+P equivalents.
    function isNext(event) {
        return event.key === Qt.Key_Down || (event.key === Qt.Key_N && (event.modifiers & Qt.ControlModifier));
    }
    function isPrevious(event) {
        return event.key === Qt.Key_Up || (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier));
    }

    readonly property var allModes: [appsMode, runMode, calcMode, clipboardMode, musicMode, playlistsMode, powerMode]

    function currentItem() {
        switch (launcher.mode) {
        case "apps": return appsMode;
        case "run": return runMode;
        case "calc": return calcMode;
        case "clipboard": return clipboardMode;
        case "music": return musicMode;
        case "playlists": return playlistsMode;
        case "power": return powerMode;
        }
        return null;
    }

    // Focus lands on the freshly-shown mode's TextInput one tick after
    // WlrKeyboardFocus flips to Exclusive, mirroring the settle delay
    // doannc's AppLauncher.qml uses for the same reason (focus requested
    // before the layer surface has keyboard focus is silently dropped).
    Timer {
        id: focusTimer
        interval: 20
        onTriggered: {
            const item = launcher.currentItem();
            if (item && item.focusInput) item.focusInput();
        }
    }

    IpcHandler {
        target: "launcher"
        function apps(): void { launcher.open("apps"); }
        function run(): void { launcher.open("run"); }
        function calc(): void { launcher.open("calc"); }
        function clipboard(): void { launcher.open("clipboard"); }
        function music(): void { launcher.open("music"); }
        function playlists(): void { launcher.open("playlists"); }
        function power(): void { launcher.open("power"); }
        function toggle(): void { launcher.toggleVisible(); }
    }

    // --- Persisted state: app frecency, favorites, recent commands ---
    property var state: ({ appUsage: {}, favoriteApps: [], recentCommands: [] })

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/quickshell"

    FileView {
        id: stateFile
        path: launcher.stateDir + "/launcher.json"
        printErrors: false
        onLoaded: {
            try {
                const parsed = JSON.parse(stateFile.text());
                launcher.state = Object.assign({ appUsage: {}, favoriteApps: [], recentCommands: [] }, parsed);
            } catch (e) {
                // Empty or corrupt file - keep defaults.
            }
        }
    }

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", launcher.stateDir]
        onExited: stateFile.reload()
    }
    Component.onCompleted: mkdirProc.running = true

    Timer {
        id: saveTimer
        interval: 300
        onTriggered: stateFile.setText(JSON.stringify(launcher.state))
    }
    function _persist() { saveTimer.restart(); }

    function recordAppUsage(id) {
        const usage = Object.assign({}, launcher.state.appUsage);
        const prev = usage[id] || { count: 0, lastUsed: 0 };
        usage[id] = { count: prev.count + 1, lastUsed: Date.now() };
        launcher.state = Object.assign({}, launcher.state, { appUsage: usage });
        launcher._persist();
    }
    function isFavoriteApp(id) {
        return launcher.state.favoriteApps.indexOf(id) >= 0;
    }
    function toggleFavoriteApp(id) {
        const favs = launcher.state.favoriteApps.slice();
        const i = favs.indexOf(id);
        if (i >= 0) favs.splice(i, 1); else favs.push(id);
        launcher.state = Object.assign({}, launcher.state, { favoriteApps: favs });
        launcher._persist();
    }
    function pushRecentCommand(cmd) {
        const list = [cmd].concat(launcher.state.recentCommands.filter(c => c !== cmd)).slice(0, 20);
        launcher.state = Object.assign({}, launcher.state, { recentCommands: list });
        launcher._persist();
    }

    // --- Backdrop ---
    MouseArea {
        anchors.fill: parent
        onClicked: launcher.close()

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.45)
            opacity: launcher.visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.motion.base } }
        }
    }

    // --- Card ---
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 680
        height: {
            const item = launcher.currentItem();
            return item ? item.preferredHeight : 480;
        }
        radius: Theme.radius.card
        color: Theme.bgElevated
        border.width: 1
        border.color: Theme.border

        scale: launcher.visible ? 1 : 0.96
        opacity: launcher.visible ? 1 : 0

        Behavior on scale { NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve } }
        Behavior on opacity { NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve } }
        Behavior on height { NumberAnimation { duration: Theme.motion.base; easing.type: Theme.motion.curve } }

        // Eat clicks so interacting with the card doesn't fall through to
        // the backdrop MouseArea and close the launcher.
        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        AppsMode {
            id: appsMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "apps"
        }
        RunMode {
            id: runMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "run"
        }
        CalcMode {
            id: calcMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "calc"
        }
        ClipboardMode {
            id: clipboardMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "clipboard"
        }
        MusicMode {
            id: musicMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "music"
        }
        PlaylistsMode {
            id: playlistsMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "playlists"
        }
        PowerMode {
            id: powerMode
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            launcher: launcher
            visible: launcher.mode === "power"
        }
    }
}
