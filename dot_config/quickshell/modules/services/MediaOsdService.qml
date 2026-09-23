pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tiny trigger bus for SeekOsd (modules/osd/SeekOsd.qml). VolumeOsd can just
// watch Pipewire's volume property directly because Pipewire pushes that
// change reactively - MPRIS position doesn't (see MediaService.tickProgress's
// comment), so there's no property here to watch the same way. Instead the
// Super+Shift+,/. seek keybinds (keymaps.lua) shell out to `mpc seek`
// followed by `qs ipc call mediaOsd seek`, which bumps `trigger` - every
// screen's SeekOsd watches that and shows itself if focused, mirroring
// VolumeOsd's isFocusedScreen pattern.
QtObject {
    id: root

    property int trigger: 0

    property IpcHandler _ipc: IpcHandler {
        target: "mediaOsd"
        function seek(): void { root.trigger++; }
    }
}
