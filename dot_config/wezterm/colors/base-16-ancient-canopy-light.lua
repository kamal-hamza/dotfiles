-- Base16 Ancient Canopy Light
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Ancient Canopy Light"] = {
        foreground = "#222920",
        background = "#f1f5ee",
        cursor_bg = "#222920",
        cursor_border = "#222920",
        cursor_fg = "#f1f5ee",
        selection_bg = "#d0d6cc",
        selection_fg = "#222920",
        
        -- Normal ANSI colors
        ansi = {
            "#f1f5ee", -- black
            "#7a4444", -- red
            "#3e5238", -- green
            "#7a783e", -- yellow
            "#324651", -- blue
            "#523e52", -- magenta
            "#3e524e", -- cyan
            "#222920", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#848e7f", -- bright black
            "#7a4444", -- bright red
            "#3e5238", -- bright green
            "#7a783e", -- bright yellow
            "#324651", -- bright blue
            "#523e52", -- bright magenta
            "#3e524e", -- bright cyan
            "#0f120e", -- bright white
        },
    }
}

return M
