-- Base16 Ancient Canopy Light
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#f1f5ee',
    base01 = '#e4e9e1',
    base02 = '#d0d6cc',
    base03 = '#848e7f',
    base04 = '#4b5448',
    base05 = '#222920',
    base06 = '#161b15',
    base07 = '#0f120e',
    base08 = '#7a4444',
    base09 = '#8e5c36',
    base0A = '#7a783e',
    base0B = '#3e5238',
    base0C = '#3e524e',
    base0D = '#324651',
    base0E = '#523e52',
    base0F = '#46392d',
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
