vim.pack.add({
    "https://github.com/neogitorg/neogit",
    "https://github.com/nvim-lua/plenary.nvim",
})

-- diffview (diffs) and fzf-lua (pickers) are loaded earlier in init.lua
require("neogit").setup({
    integrations = {
        diffview = true,
        fzf_lua = true,
    },
})

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
