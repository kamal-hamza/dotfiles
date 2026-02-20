-- Base16 Hearth
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#120f0d',
    base01 = '#1a1614',
    base02 = '#2a2421',
    base03 = '#5c524d',
    base04 = '#a89991',
    base05 = '#e6ddd8',
    base06 = '#f2ebe6',
    base07 = '#fffaf7',
    base08 = '#d46a55',
    base09 = '#e8a87c',
    base0A = '#c29b61',
    base0B = '#8e9e78',
    base0C = '#7d9ba1',
    base0D = '#6b8da1',
    base0E = '#a1869e',
    base0F = '#8c6b5d',
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
