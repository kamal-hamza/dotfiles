vim.pack.add({ "https://github.com/chrisgrieser/nvim-spider" })

vim.keymap.set({ "n", "o", "x" }, "w", "<Cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<Cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<Cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
vim.keymap.set({ "n", "o", "x" }, "ge", "<Cmd>lua require('spider').motion('ge')<CR>", { desc = "Spider-ge" })
