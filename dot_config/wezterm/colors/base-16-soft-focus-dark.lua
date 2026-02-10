-- Base16 Soft Focus Dark
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Soft Focus Dark"] = {
        foreground = "#f5f5f5",
        background = "#050505",
        cursor_bg = "#f5f5f5",
        cursor_border = "#f5f5f5",
        cursor_fg = "#050505",
        selection_bg = "#2a2a2a",
        selection_fg = "#f5f5f5",
        
        -- Normal ANSI colors
        ansi = {
            "#050505", -- black
            "#ff4c6a", -- red
            "#99cc99", -- green
            "#d4b87b", -- yellow
            "#448cbb", -- blue
            "#b88e8d", -- magenta
            "#67b7f5", -- cyan
            "#f5f5f5", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#3a3a3a", -- bright black
            "#ff4c6a", -- bright red
            "#99cc99", -- bright green
            "#d4b87b", -- bright yellow
            "#448cbb", -- bright blue
            "#b88e8d", -- bright magenta
            "#67b7f5", -- bright cyan
            "#ffffff", -- bright white
        },
    }
}

return M
