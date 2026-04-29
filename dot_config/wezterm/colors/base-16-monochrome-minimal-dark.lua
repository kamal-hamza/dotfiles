-- Base16 Monochrome Minimal Dark
-- Scheme author: Custom
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#101010',
    base01 = '#272727',
    base02 = '#272727',
    base03 = '#474747',
    base04 = '#50585d',
    base05 = '#b0b0b0',
    base06 = '#ffffff',
    base07 = '#ffffff',
    base08 = '#777777',
    base09 = '#d9ba73',
    base0A = '#d9ba73',
    base0B = '#ffffff',
    base0C = '#777777',
    base0D = '#ffffff',
    base0E = '#ffffff',
    base0F = '#777777',
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
