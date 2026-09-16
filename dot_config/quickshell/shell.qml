import Quickshell
import "modules/bar"
import "modules/notifications"
import "modules/osd"
import "modules/launcher"

// Entry point. Keep this file thin: it only wires top-level modules
// together and instantiates them per output. Each module lives in its
// own directory under modules/ and is self-contained.
//
// NotificationService and MediaService (modules/notifications,
// modules/services) are qmldir singletons - created exactly once no matter
// how many widgets reference them, so they need no explicit instantiation
// here.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        Toasts {}
    }

    Variants {
        model: Quickshell.screens

        VolumeOsd {}
    }

    // Rofi replacement: one shared launcher window (Apps/Run/Calc/
    // Clipboard/Music/Power), not per-screen - see
    // modules/launcher/Launcher.qml for the `qs ipc call launcher <mode>`
    // entry points bound in hypr/conf/keymaps.lua.
    Launcher {}
}
