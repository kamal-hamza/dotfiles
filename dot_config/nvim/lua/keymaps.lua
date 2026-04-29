print("Keymaps Loaded")
-- terminal to normal mode
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- vim diagnostics
vim.keymap.set('n', '<leader>td', vim.diagnostic.open_float, { desc = "Show Diagnostics" })

-- Move between windows using Ctrl + h/j/k/l
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- navigate completion menu with Tab and S-Tab
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

-- resize windows
vim.keymap.set('n', '<A-up>', ':resize -2<CR>')
vim.keymap.set('n', '<A-down>', ':resize +2<CR>')
vim.keymap.set('n', '<A-left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<A-right>', ':vertical resize +2<CR>')

-- macos options key fix
vim.keymap.set('n', '<M-f>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<M-b>', ':vertical resize +2<CR>')

-- lsp keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition)

-- buffer delete
vim.keymap.set("n", "<leader>db", function() vim.cmd("bdelete") end, { desc = "Delete Buffer" })
