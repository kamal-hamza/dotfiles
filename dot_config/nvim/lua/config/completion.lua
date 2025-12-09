-- Completion Configuration
-- NOTE: This config now uses nvim-cmp (see plugins/nvim-cmp.lua) instead of native completion
-- nvim-cmp provides LSP-powered autocompletion with snippet support

-- Keep these settings for general completion behavior
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.pumheight = 15        -- Max items in completion menu
vim.opt.shortmess:append('c') -- Don't show completion messages

return {}
