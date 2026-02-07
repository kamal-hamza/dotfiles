-- Base16 Hearth
-- Scheme author: Hamza Kamal
-- Template author: Hamza Kamal

local M = {}

M.scheme = {
    ["Hearth"] = {
        foreground = "#e6ddd8",
        background = "#120f0d",
        cursor_bg = "#e6ddd8",
        cursor_border = "#e6ddd8",
        cursor_fg = "#120f0d",
        selection_bg = "#2a2421",
        selection_fg = "#e6ddd8",
        
        -- Normal ANSI colors
        ansi = {
            "#120f0d", -- black
            "#d46a55", -- red
            "#8e9e78", -- green
            "#c29b61", -- yellow
            "#6b8da1", -- blue
            "#a1869e", -- magenta
            "#7d9ba1", -- cyan
            "#e6ddd8", -- white
        },
        
        -- Bright ANSI colors
        brights = {
            "#5c524d", -- bright black
            "#d46a55", -- bright red
            "#8e9e78", -- bright green
            "#c29b61", -- bright yellow
            "#6b8da1", -- bright blue
            "#a1869e", -- bright magenta
            "#7d9ba1", -- bright cyan
            "#fffaf7", -- bright white
        },
    }
}

return M
