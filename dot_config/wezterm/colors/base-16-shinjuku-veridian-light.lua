-- Base16 Shinjuku Veridian Light
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#f7faf9',
    base01 = '#edf2f1',
    base02 = '#dbe6e4',
    base03 = '#8ca6a2',
    base04 = '#4a6360',
    base05 = '#1f2b29',
    base06 = '#151c1b',
    base07 = '#0d1211',
    base08 = '#a33e3e',
    base09 = '#3d7a78',
    base0A = '#5c7a3d',
    base0B = '#1f5e54',
    base0C = '#32635d',
    base0D = '#2d5c73',
    base0E = '#424a63',
    base0F = '#293836',
}

local active_tab = {
    bg_color = palette.base01,
    fg_color = palette.base05,
}

local inactive_tab = {
    bg_color = palette.base00,
    fg_color = palette.base03,
}

function M.colors()
    return {
        foreground = palette.base05,
        background = palette.base00,
        cursor_bg = palette.base05,
        cursor_border = palette.base05,
        cursor_fg = palette.base00,
        selection_bg = palette.base02,
        selection_fg = palette.base05,

        ansi = {
            palette.base00,
            palette.base08,
            palette.base0B,
            palette.base0A,
            palette.base0D,
            palette.base0E,
            palette.base0C,
            palette.base05,
        },

        brights = {
            palette.base03,
            palette.base08,
            palette.base0B,
            palette.base0A,
            palette.base0D,
            palette.base0E,
            palette.base0C,
            palette.base07,
        },

        tab_bar = {
            background = palette.base00,
            active_tab = active_tab,
            inactive_tab = inactive_tab,
            inactive_tab_hover = active_tab,
            new_tab = inactive_tab,
            new_tab_hover = active_tab,
            inactive_tab_edge = palette.base03,
        },
    }
end

function M.window_frame()
    return {
        active_titlebar_bg = palette.base00,
        inactive_titlebar_bg = palette.base00,
    }
end

return M
