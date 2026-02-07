-- Base16 Pacific Umbra Dark
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Pacific Umbra Dark"] = {
        foreground = "#9da6a8",
        background = "#0a0e0f",
        cursor_bg = "#9da6a8",
        cursor_border = "#9da6a8",
        cursor_fg = "#0a0e0f",
        selection_bg = "#232a2c",
        selection_fg = "#9da6a8",
        
        -- Normal ANSI colors
        ansi = {
            "#0a0e0f", -- black
            "#889b94", -- red
            "#4b5d56", -- green
            "#8fa099", -- yellow
            "#526a76", -- blue
            "#7a7d84", -- magenta
            "#6a8082", -- cyan
            "#9da6a8", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#3f4a4c", -- bright black
            "#889b94", -- bright red
            "#4b5d56", -- bright green
            "#8fa099", -- bright yellow
            "#526a76", -- bright blue
            "#7a7d84", -- bright magenta
            "#6a8082", -- bright cyan
            "#e0e5e6", -- bright white
        },
    }
}

return M
