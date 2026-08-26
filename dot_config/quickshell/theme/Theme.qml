pragma Singleton
import QtQuick

// Central place for colors and sizing. Widgets should read from here
// instead of hardcoding values, so the whole shell can be reskinned
// by editing only this file.
QtObject {
    // Colors (Catppuccin Mocha)
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#45475a"
    readonly property color outline: "#585b70"
    readonly property color accent: "#89b4fa"
    readonly property color text: "#cdd6f4"
    readonly property color textOnAccent: "#1e1e2e"

    // Type
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // Shared
    readonly property int animationMs: 120

    // Bar
    readonly property int barHeight: 34

    // Workspace indicator
    readonly property int workspaceSize: 24
    readonly property int workspaceRadius: 6
    readonly property int workspaceSpacing: 6

    // Popups / dropdown cards
    readonly property int cardRadius: 16
}
