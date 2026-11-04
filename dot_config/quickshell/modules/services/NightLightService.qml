pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Manual night light: hyprsunset tints the screen for as long as its process
// runs, and the compositor restores normal colors once it exits, fading both
// ways itself (render:ctm_animation). Lives here rather than in the widget
// because Bar is instantiated per output, and each one must share this single
// process.
Singleton {
    id: root

    readonly property int temperature: 3800
    // Follows the process, so the bar stays accurate if hyprsunset dies.
    readonly property bool active: hyprsunsetProc.running

    function toggle() {
        hyprsunsetProc.running = !hyprsunsetProc.running;
    }

    Process {
        id: hyprsunsetProc
        command: ["hyprsunset", "-t", String(root.temperature)]
    }
}
