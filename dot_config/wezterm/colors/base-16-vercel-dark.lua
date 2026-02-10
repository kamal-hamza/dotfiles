-- Base16 Vercel Dark
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Vercel Dark"] = {
        foreground = "#ededed",
        background = "#000000",
        cursor_bg = "#ededed",
        cursor_border = "#ededed",
        cursor_fg = "#000000",
        selection_bg = "#333333",
        selection_fg = "#ededed",
        
        -- Normal ANSI colors
        ansi = {
            "#000000", -- black
            "#f75f8f", -- red
            "#62c073", -- green
            "#fcee0a", -- yellow
            "#52a8ff", -- blue
            "#c472fb", -- magenta
            "#1da9b0", -- cyan
            "#ededed", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#666666", -- bright black
            "#f75f8f", -- bright red
            "#62c073", -- bright green
            "#fcee0a", -- bright yellow
            "#52a8ff", -- bright blue
            "#c472fb", -- bright magenta
            "#1da9b0", -- bright cyan
            "#ffffff", -- bright white
        },
    }
}

return M
