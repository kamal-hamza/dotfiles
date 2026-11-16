import QtQuick
import Quickshell.Services.Pipewire
import "../../theme"
import "../common"

// Volume pill: shows the default sink's volume, scroll to adjust it, click
// opens the full AudioPopup (output/input/per-app mixer) instead of
// spawning pavucontrol.
Pill {
    id: root

    property bool open: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Keeps the sink's audio properties bound and updating - Pipewire
    // nodes are otherwise inert until something expresses interest.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    active: root.open

    Text {
        text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.font.md
        font.bold: true
        color: root.muted ? Theme.textTertiary : Theme.textPrimary
    }

    onClicked: root.open = !root.open
    onWheel: wheel => {
        if (!root.sink?.audio)
            return;

        const step = 0.05;
        root.sink.audio.volume = wheel.angleDelta.y > 0
            ? Math.min(1, root.volume + step)
            : Math.max(0, root.volume - step);
    }
}
