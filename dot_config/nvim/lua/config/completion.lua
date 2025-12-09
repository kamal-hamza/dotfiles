-- Native Neovim completion configuration (Neovim 0.11+)
-- This replaces blink.cmp with built-in LSP completion

-- Configure completion behavior
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 15 -- Max items in completion menu

-- Completion display settings
vim.opt.shortmess:append('c') -- Don't show completion messages

-- Configure completion menu appearance using highlight groups
local function setup_completion_highlights()
    -- Get colors from current theme
    local theme_name = vim.g.colors_name or "soft-focus-dark"
    local theme_module = "plugins.themes." .. theme_name
    local has_theme, theme = pcall(require, theme_module)

    local colors
    if has_theme and theme.colors then
        colors = theme.colors
    else
        -- Fallback colors
        colors = {
            bg = "#0a0a0a",
            bg_alt = "#0f0f0f",
            bg_elevated = "#1a1a1a",
            fg = "#e0e0e0",
            fg_alt = "#b0b0b0",
            cursor_line = "#1a1a1a",
            border = "#303030",
        }
    end

    -- Completion menu highlights
    vim.api.nvim_set_hl(0, 'Pmenu', { bg = colors.bg, fg = colors.fg })
    vim.api.nvim_set_hl(0, 'PmenuSel', { bg = colors.cursor_line, fg = colors.fg, bold = true })
    vim.api.nvim_set_hl(0, 'PmenuSbar', { bg = colors.bg_alt })
    vim.api.nvim_set_hl(0, 'PmenuThumb', { bg = colors.border })
    vim.api.nvim_set_hl(0, 'PmenuKind', { bg = colors.bg, fg = colors.fg_alt })
    vim.api.nvim_set_hl(0, 'PmenuKindSel', { bg = colors.cursor_line, fg = colors.fg_alt, bold = true })
    vim.api.nvim_set_hl(0, 'PmenuExtra', { bg = colors.bg, fg = colors.fg_alt })
    vim.api.nvim_set_hl(0, 'PmenuExtraSel', { bg = colors.cursor_line, fg = colors.fg_alt })
end

-- Apply highlights on startup and colorscheme change
setup_completion_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_completion_highlights,
    desc = "Update completion menu colors on colorscheme change"
})

return {}
