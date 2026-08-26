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
        "zls",
        "bash-language-server",
        "powershell-editor-services",
        "gopls",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "yaml-language-server",
        "css-lsp",
        "qmlls",
        -- formatters / linters
        "stylua",
        "prettier",
        "eslint_d",
        "ruff",
        "clang-format",
        "csharpier",
        "gdtoolkit",
        "shellcheck",
        "shfmt",
        "golangci-lint",
        "gofumpt",
        "goimports",
        "hadolint",
        "dockerfmt",
        "actionlint",
        "stylelint",
        -- qmllint/qmlformat aren't on mason; they ship with Qt itself
        -- (e.g. `pacman -S qt6-declarative` on Arch)
    },
})
