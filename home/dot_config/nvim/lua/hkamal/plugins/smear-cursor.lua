vim.pack.add({ "https://github.com/sphamba/smear-cursor.nvim" })

-- follow the text color so the cursor stays visible on light and dark themes
local function set_cursor_color()
    local fg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).fg
    vim.api.nvim_set_hl(0, "SmearCursorColor", { bg = fg })
end

-- smear-cursor forces every mode's guicursor group to SmearCursorHideable and
-- redefines it without a bg, which makes nvim reset the real cursor to the
-- terminal's default color; keep the bg so nvim sets the color instead
local color = require("smear_cursor.color")

local function set_real_cursor(blend)
    local bg = vim.api.nvim_get_hl(0, { name = "SmearCursorColor", link = false }).bg
    vim.api.nvim_set_hl(0, "SmearCursorHideable", { bg = bg, blend = blend })
end

color.hide_real_cursor = function() set_real_cursor(100) end
color.unhide_real_cursor = function() set_real_cursor(0) end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        set_cursor_color()
        set_real_cursor(0)
    end,
})

require("smear_cursor").setup({ cursor_color = "SmearCursorColor" })
