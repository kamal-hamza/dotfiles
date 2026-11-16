-- WezTerm, styled after macOS Terminal.app's default "Basic" profile (dark mode):
-- SF Mono (Nerd Font) 11, white on #1e1e1e, grey non-blinking block cursor, Terminal.app's
-- ANSI palette, 80x24 window, scrollbar, no transparency/blur/ligatures.
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find("darwin") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- Windows: PowerShell 7 (fish/zsh are macOS/Linux only)
if is_windows then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- ── font ────────────────────────────────────────────────────────────────────
-- SF Mono patched with Nerd Font icons, from packages-<os>.yaml (AUR
-- nerd-fonts-sf-mono = "SFMono Nerd Font Mono", cask font-sf-mono-nerd-font
-- = "SFMono Nerd Font"). Then plain SF Mono / Menlo / Meslo; JetBrains Mono
-- (bundled with wezterm) catches anything else.
config.font = wezterm.font_with_fallback({
    "SFMono Nerd Font Mono",
    "SFMono Nerd Font",
    "SF Mono",
    "Menlo",
    "MesloLGS Nerd Font Mono",
    "JetBrains Mono",
})
config.font_size = 11
config.line_height = 1.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- Terminal.app has no ligatures
config.bold_brightens_ansi_colors = "BrightAndBold" -- "Use bright colors for bold text"

-- ── colors: Terminal.app Basic (dark) ───────────────────────────────────────
config.colors = {
    foreground = "#ffffff",
    background = "#1e1e1e",
    cursor_bg = "#929292",
    cursor_fg = "#1e1e1e",
    cursor_border = "#929292",
    selection_bg = "#3f638b",
    selection_fg = "#ffffff",
    scrollbar_thumb = "#5a5a5a",
    split = "#3a3a3a",
    ansi = { "#000000", "#c23621", "#25bc24", "#adad27", "#492ee1", "#d338d3", "#33bbc8", "#cbcccd" },
    brights = { "#818383", "#fc391f", "#31e722", "#eaec23", "#5833ff", "#f935f8", "#14f0f0", "#e9ebeb" },
}

-- ── cursor ──────────────────────────────────────────────────────────────────
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
config.force_reverse_video_cursor = false

-- ── window ──────────────────────────────────────────────────────────────────
config.initial_cols = 80
config.initial_rows = 24
config.window_padding = { left = 4, right = 4, top = 2, bottom = 2 }
config.enable_scroll_bar = true
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0
config.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"
config.audible_bell = "Disabled"
config.visual_bell = { fade_in_duration_ms = 0, fade_out_duration_ms = 0 }
-- Native title bar on macOS/Windows. Hyprland tiles windows without
-- titlebars, so draw nothing on Linux.
config.window_decorations = (is_mac or is_windows) and "TITLE | RESIZE" or "NONE"

-- Tabs: native-looking bar, only shown when there's more than one tab
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.window_frame = {
    font = wezterm.font({ family = "SF Pro Text", weight = "Bold" }),
    font_size = 12,
    active_titlebar_bg = "#2b2b2b",
    inactive_titlebar_bg = "#2b2b2b",
}

-- Title like Terminal.app: "user — process — 80×24"
wezterm.on("format-window-title", function(tab, _, _, _, _)
    local info = tab.active_pane
    local proc = (info.foreground_process_name or ""):match("([^/\\]+)$")
    if not proc or proc == "" then
        proc = info.title
    end
    local user = os.getenv("USER") or os.getenv("USERNAME") or ""
    local pane = wezterm.mux.get_pane(info.pane_id)
    local dims = ""
    if pane then
        local size = pane:get_dimensions()
        dims = string.format(" — %d×%d", size.cols, size.viewport_rows)
    end
    return string.format("%s — %s%s", user, proc, dims)
end)

-- ── behaviour ───────────────────────────────────────────────────────────────
config.scrollback_lines = 10000
config.enable_kitty_graphics = true -- image.nvim (kitty backend)
config.term = "xterm-256color"
-- Option acts as Alt on the left key (fish Alt+Tab, vim), like before.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.check_for_updates = false

return config
