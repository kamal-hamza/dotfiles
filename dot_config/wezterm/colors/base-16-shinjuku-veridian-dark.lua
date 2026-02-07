-- Base16 Shinjuku Veridian
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Shinjuku Veridian"] = {
        foreground = "#dbe6e4",
        background = "#0d1211",
        cursor_bg = "#dbe6e4",
        cursor_border = "#dbe6e4",
        cursor_fg = "#0d1211",
        selection_bg = "#1f2b29",
        selection_fg = "#dbe6e4",
        
        -- Normal ANSI colors
        ansi = {
            "#0d1211", -- black
            "#e68a8a", -- red
            "#2d8c7d", -- green
            "#9ec481", -- yellow
            "#4a86a3", -- blue
            "#717ea3", -- magenta
            "#52a399", -- cyan
            "#dbe6e4", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#4a6360", -- bright black
            "#e68a8a", -- bright red
            "#2d8c7d", -- bright green
            "#9ec481", -- bright yellow
            "#4a86a3", -- bright blue
            "#717ea3", -- bright magenta
            "#52a399", -- bright cyan
            "#f7faf9", -- bright white
        },
    }
}

return M
