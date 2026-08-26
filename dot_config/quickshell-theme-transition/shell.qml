import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Standalone Quickshell config, spawned fresh by `theme set <name>` for the
// duration of a single theme switch (see dot_local/bin/executable_theme).
// Deliberately independent from dot_config/quickshell/ (the in-progress bar
// project) - this process starts, plays one transition, and exits.
//
// Purely a visual surface - dot_local/bin/executable_theme owns all the
// sequencing: it takes the screenshot, spawns this, waits for it to paint,
// runs the real theme apply itself, then writes to a marker file this watches
// to know when to start revealing. (An earlier version tried to have this
// QML spawn the apply step itself via Quickshell.Io.Process and react to its
// `exited` signal, but that signal never fired reliably here even though the
// process demonstrably completed - FileView's documented fileChanged()
// is a lot more certain, so that's the trigger instead.)
ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overlay

            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "theme-transition"
            focusable: false

            // Global cursor position (from `hyprctl cursorpos`), converted to
            // this screen's local coordinates. If the cursor isn't actually
            // on this screen (multi-monitor), falls back to this screen's
            // own center so every monitor still gets a sensible reveal point.
            property real globalCx: Number(Quickshell.env("THEME_TRANSITION_CX"))
            property real globalCy: Number(Quickshell.env("THEME_TRANSITION_CY"))
            property real localCx: globalCx - screen.x
            property real localCy: globalCy - screen.y
            property bool cursorOnThisScreen: localCx >= 0 && localCx <= width && localCy >= 0 && localCy <= height
            property real cx: cursorOnThisScreen ? localCx : width / 2
            property real cy: cursorOnThisScreen ? localCy : height / 2
            property real maxRadius: Math.hypot(Math.max(cx, width - cx), Math.max(cy, height - cy))

            Image {
                id: oldShot
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                cache: false
                source: "file://" + Quickshell.env("THEME_TRANSITION_IMAGE_DIR") + "/" + overlay.modelData.name + ".png"
            }

            Rectangle {
                id: mask
                width: 0
                height: width
                radius: width / 2
                color: "black"
                x: overlay.cx - width / 2
                y: overlay.cy - height / 2
                visible: false
                layer.enabled: true
            }

            MultiEffect {
                anchors.fill: parent
                source: oldShot
                maskEnabled: true
                maskSource: mask
                maskInverted: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.05
            }

            // The bash orchestrator pre-creates this file empty, then writes
            // to it once the real theme apply has finished underneath us.
            FileView {
                path: Quickshell.env("THEME_TRANSITION_READY_FILE")
                watchChanges: true
                onFileChanged: revealAnim.start()
            }

            NumberAnimation {
                id: revealAnim
                target: mask
                property: "width"
                from: 0
                to: overlay.maxRadius * 2 + 40
                duration: 900
                easing.type: Easing.InOutCubic
                onFinished: Qt.quit()
            }
        }
    }
}
