-- Base16 Pacific Umbra Light
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#e0e5e6',
    base01 = '#d1d9da',
    base02 = '#c1c8c9',
    base03 = '#9da6a8',
    base04 = '#5a6668',
    base05 = '#232a2c',
    base06 = '#141a1b',
    base07 = '#0a0e0f',
    base08 = '#5f736b',
    base09 = '#4a5e60',
    base0A = '#6b7d75',
    base0B = '#3b4d46',
    base0C = '#4a6062',
    base0D = '#324a56',
    base0E = '#5a5d64',
    base0F = '#2e3430',
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
