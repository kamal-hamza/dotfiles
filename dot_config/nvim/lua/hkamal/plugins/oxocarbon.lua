vim.pack.add({ "https://github.com/nyoom-engineering/oxocarbon.nvim" })

vim.opt.background = "dark"
vim.cmd.colorscheme("oxocarbon")

local black = 0x000000

-- groups whose foreground carries text/icons: keep fg, blacken bg only
local bg_only = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "StatusLine",
    "StatusLineNC",
    "Pmenu",
    "PmenuSbar",
    "PmenuThumb",
    "NvimTreeNormal",
    "NvimTreeNormalNC",
    "NvimTreeEndOfBuffer",
    "FzfLuaNormal",
    "FzfLuaPreviewNormal",
    "FzfLuaFzfNormal",
    "FzfLuaFzfGutter",
}

-- border/separator groups: blend fg into bg for a seamless black edge
local bg_and_fg = {
    "FloatBorder",
    "WinSeparator",
    "VertSplit",
    "NvimTreeWinSeparator",
    "FzfLuaBorder",
    "FzfLuaPreviewBorder",
    "FzfLuaFzfBorder",
}

for _, group in ipairs(bg_only) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    hl.bg = black
    vim.api.nvim_set_hl(0, group, hl)
end

for _, group in ipairs(bg_and_fg) do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    hl.bg = black
    hl.fg = black
    vim.api.nvim_set_hl(0, group, hl)
end
