-- Base16 Ancient Canopy
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Ancient Canopy"] = {
        foreground = "#d0d6cc",
        background = "#0f120e",
        cursor_bg = "#d0d6cc",
        cursor_border = "#d0d6cc",
        cursor_fg = "#0f120e",
        selection_bg = "#222920",
        selection_fg = "#d0d6cc",
        
        -- Normal ANSI colors
        ansi = {
            "#0f120e", -- black
            "#9b6a6a", -- red
            "#5d7a54", -- green
            "#a3a164", -- yellow
            "#4b6a7a", -- blue
            "#7a647a", -- magenta
            "#5d7a74", -- cyan
            "#d0d6cc", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#4b5448", -- bright black
            "#9b6a6a", -- bright red
            "#5d7a54", -- bright green
            "#a3a164", -- bright yellow
            "#4b6a7a", -- bright blue
            "#7a647a", -- bright magenta
            "#5d7a74", -- bright cyan
            "#f1f5ee", -- bright white
        },
    }
}

return M
