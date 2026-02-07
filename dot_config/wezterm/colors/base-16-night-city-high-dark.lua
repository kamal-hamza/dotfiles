-- Base16 Night City High
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Night City High"] = {
        foreground = "#e0e0e0",
        background = "#050505",
        cursor_bg = "#e0e0e0",
        cursor_border = "#e0e0e0",
        cursor_fg = "#050505",
        selection_bg = "#1a1a1a",
        selection_fg = "#e0e0e0",
        
        -- Normal ANSI colors
        ansi = {
            "#050505", -- black
            "#ff003c", -- red
            "#39ff14", -- green
            "#00ff9f", -- yellow
            "#4deeea", -- blue
            "#7400ff", -- magenta
            "#00f3ff", -- cyan
            "#e0e0e0", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#404040", -- bright black
            "#ff003c", -- bright red
            "#39ff14", -- bright green
            "#00ff9f", -- bright yellow
            "#4deeea", -- bright blue
            "#7400ff", -- bright magenta
            "#00f3ff", -- bright cyan
            "#ffffff", -- bright white
        },
    }
}

return M
