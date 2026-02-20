-- Base16 White Sands Light
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

local palette = {
    base00 = '#f7fbff',
    base01 = '#ecf4f7',
    base02 = '#d9e8f0',
    base03 = '#8baec2',
    base04 = '#4a6b7d',
    base05 = '#1c2f38',
    base06 = '#121f26',
    base07 = '#0a141a',
    base08 = '#e11d48',
    base09 = '#ea580c',
    base0A = '#ca8a04',
    base0B = '#0891b2',
    base0C = '#06b6d4',
    base0D = '#0284c7',
    base0E = '#7c3aed',
    base0F = '#db2777',
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
