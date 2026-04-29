-- Base16 Breeze Dark
-- Scheme author: KDE (Ported)
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#232627',
    base01 = '#31363b',
    base02 = '#4d5057',
    base03 = '#7f8c8d',
    base04 = '#a8b2b3',
    base05 = '#fcfcfc',
    base06 = '#fdfdfd',
    base07 = '#ffffff',
    base08 = '#1abc9c',
    base09 = '#9b59b6',
    base0A = '#fdbc4b',
    base0B = '#ed1515',
    base0C = '#f67400',
    base0D = '#11d116',
    base0E = '#1d99f3',
    base0F = '#c0392b',
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
