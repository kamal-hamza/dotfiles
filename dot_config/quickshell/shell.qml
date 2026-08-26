import Quickshell
import "modules/bar"

// Entry point. Keep this file thin: it only wires top-level modules
// together and instantiates them per output. Each module lives in its
// own directory under modules/ and is self-contained.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
