vim.pack.add({ "https://github.com/MagicDuck/grug-far.nvim" })

require("grug-far").setup({})

vim.keymap.set("n", "<leader>sr", "<Cmd>GrugFar<CR>", { desc = "Search and Replace" })
