-- minimal netrw sidebar: no banner, tree-style listing, narrow width,
-- files open in the window that was focused before the explorer
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1

vim.keymap.set("n", "<leader>ee", "<cmd>Lexplore<cr>", { desc = "Toggle Explorer" })
