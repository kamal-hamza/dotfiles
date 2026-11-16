vim.pack.add({ "https://github.com/folke/trouble.nvim" })

require("trouble").setup({})

vim.keymap.set("n", "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set(
    "n",
    "<leader>xX",
    "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
    { desc = "Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>xL", "<Cmd>Trouble loclist toggle<CR>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xQ", "<Cmd>Trouble qflist toggle<CR>", { desc = "Quickfix List (Trouble)" })
