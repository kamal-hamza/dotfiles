vim.pack.add({ "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" })

require("mason-tool-installer").setup({
    ensure_installed = {
        -- lsp servers
        "emmylua_ls",
        "tsgo",
        "tailwindcss-language-server",
        "pyrefly",
        "rust-analyzer",
        "clangd",
        "taplo",
        "json-lsp",
        "roslyn-language-server",
        -- formatters / linters
        "stylua",
        "prettier",
        "eslint_d",
        "ruff",
        "clang-format",
        "csharpier",
    },
})
