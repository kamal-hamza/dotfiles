-- Completion Configuration for coc.nvim
-- coc.nvim handles completion with its own engine and settings

-- General completion settings
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.pumheight = 20        -- Max items in completion menu
vim.opt.shortmess:append('c') -- Don't show completion messages

-- Update time for better performance with coc.nvim
vim.opt.updatetime = 300

-- Always show the signcolumn (for diagnostics)
vim.opt.signcolumn = "yes"

return {}
