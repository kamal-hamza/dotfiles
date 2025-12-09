return {
    -- Mason: LSP/DAP/Linter/Formatter installer
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                    border = "rounded",
                },
            })
        end,
    },

    -- Mason LSPConfig bridge
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            -- List of servers for mason to install
            ensure_installed = {
                "lua_ls", -- Lua
                "ts_ls", -- TypeScript/JavaScript
                "html", -- HTML
                "cssls", -- CSS
                "tailwindcss", -- Tailwind CSS
                "svelte", -- Svelte
                "graphql", -- GraphQL
                "emmet_ls", -- Emmet
                "prismals", -- Prisma
                "pyright", -- Python
                "eslint", -- ESLint
                "jsonls", -- JSON
                "yamlls", -- YAML
                "bashls", -- Bash
                "marksman", -- Markdown
            },
            -- Auto-install configured servers (with lspconfig)
            automatic_installation = true,
        },
    },

    -- Mason Tool Installer for formatters/linters
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                -- Formatters
                "prettier", -- JS/TS/JSON/YAML/Markdown/CSS/HTML
                "prettierd", -- Faster prettier
                "stylua", -- Lua
                "isort", -- Python import sorting
                "black", -- Python
                "shfmt", -- Shell

                -- Linters
                "eslint_d", -- JS/TS
                "pylint", -- Python
            },
            auto_update = false,
            run_on_start = true,
        },
    },
}
