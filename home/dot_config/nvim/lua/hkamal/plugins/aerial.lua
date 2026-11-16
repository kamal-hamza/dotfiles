vim.pack.add({ "https://github.com/stevearc/aerial.nvim" })

require("aerial").setup({
    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = {
        default_direction = "left",
        width = 40,
    },
})

vim.api.nvim_create_user_command("Symbols", "AerialToggle", { desc = "Toggle Outline (Aerial)" })
