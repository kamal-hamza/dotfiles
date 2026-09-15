pragma Singleton
import QtQuick

// Central place for colors and sizing. Every value below is lifted directly
// from waybar/style.css, mako/config, and hypr/conf/looks.lua's border
// gradients - this shell's palette is monochrome by design, and stays that
// way so Quickshell matches the rest of the desktop instead of introducing
// its own theme.
QtObject {
    // Surfaces
    readonly property color bg: "#050505"
    readonly property color bgElevated: "#0a0a0a"
    readonly property color bgHover: "#101010"
    readonly property color bgControl: "#141414"

    // Borders
    readonly property color border: "#272727"
    readonly property color borderMid: "#474747"
    readonly property color borderStrong: "#666666"
    readonly property color borderHover: "#ffffff"

    // Text
    readonly property color textPrimary: "#d4d4d4"
    readonly property color textSecondary: "#b0b0b0"
    readonly property color textTertiary: "#8d8d8d"
    readonly property color textDisabled: "#666666"
    readonly property color textStrong: "#ffffff"

    // Active/selected fills - inverted treatment (white fill, near-black
    // content), the same convention mako uses for critical urgency and
    // waybar uses for the active workspace.
    readonly property color emphasis: "#ffffff"
    readonly property color textOnEmphasis: "#050505"

    // Type
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property QtObject font: QtObject {
        readonly property int xs: 11
        readonly property int sm: 12
        readonly property int md: 13
        readonly property int lg: 16
        readonly property int xl: 18
        readonly property int display: 26
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
    }

    readonly property QtObject radius: QtObject {
        readonly property int control: 10
        readonly property int pill: 16
        readonly property int card: 16
    }

    readonly property QtObject motion: QtObject {
        readonly property int fast: 100
        readonly property int base: 150
        readonly property int slow: 220
        readonly property int curve: Easing.OutCubic
    }

    // Bar
    readonly property int barHeight: 42
    readonly property int pillHeight: 32

    // Workspace indicator
    readonly property int workspaceSize: 28
    readonly property int workspaceRadius: 8
    readonly property int workspaceSpacing: 8
}
