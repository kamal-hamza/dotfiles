return {
    {
        "luckasRanarison/tailwind-tools.nvim",
        name = "tailwind-tools",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            server = {
                -- Don't override LSP setup, let mason-lspconfig handle it
                override = false,
            },
            cmp = {
                highlight = "background",
            },
        },
    }
}
