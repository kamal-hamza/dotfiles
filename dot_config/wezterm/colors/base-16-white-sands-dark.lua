-- Base16 White Sands
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["White Sands"] = {
        foreground = "#d9e8f0",
        background = "#0a141a",
        cursor_bg = "#d9e8f0",
        cursor_border = "#d9e8f0",
        cursor_fg = "#0a141a",
        selection_bg = "#1c2f38",
        selection_fg = "#d9e8f0",
        
        -- Normal ANSI colors
        ansi = {
            "#0a141a", -- black
            "#ff6b8b", -- red
            "#22d3ee", -- green
            "#f0d68a", -- yellow
            "#0ea5e9", -- blue
            "#a78bfa", -- magenta
            "#76e4f7", -- cyan
            "#d9e8f0", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#4a6b7d", -- bright black
            "#ff6b8b", -- bright red
            "#22d3ee", -- bright green
            "#f0d68a", -- bright yellow
            "#0ea5e9", -- bright blue
            "#a78bfa", -- bright magenta
            "#76e4f7", -- bright cyan
            "#f7fbff", -- bright white
        },
    }
}

return M
