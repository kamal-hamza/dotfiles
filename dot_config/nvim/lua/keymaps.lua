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
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { desc = 'Resize window up' })
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { desc = 'Resize window down' })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { desc = 'Resize window left' })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { desc = 'Resize window right' })

-- macos options key fix
vim.keymap.set('n', '<M-f>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<M-b>', ':vertical resize +2<CR>')

-- lsp keymaps
-- Navigation
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gD", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Go to Definition (Split)" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })
vim.keymap.set("n", "gT", function()
  vim.cmd("vsplit")
  vim.lsp.buf.type_definition()
end, { desc = "Go to Type Definition (Split)" })

-- Information
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- Refactoring
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

-- Diagnostics
vim.keymap.set("n", "<leader>ll", vim.diagnostic.setloclist, { desc = "Diagnostics List" })

-- formatter keymaps
vim.keymap.set("n", "<leader>F", "<cmd>Format<cr>", { desc = "Format Buffer" })
vim.keymap.set("v", "<leader>F", "<cmd>FormatRange<cr>", { desc = "Format Selection" })

-- buffer delete
vim.keymap.set("n", "<leader>db", function() vim.cmd("bdelete") end, { desc = "Delete Buffer" })
