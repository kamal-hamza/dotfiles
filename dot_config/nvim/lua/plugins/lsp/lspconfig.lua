return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/lazydev.nvim",                  ft = "lua",   opts = {} },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local keymap = vim.keymap

        -- Enable capabilities for autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Register pyrefly as a custom LSP server (not built into lspconfig)
        if not configs.pyrefly then
            configs.pyrefly = {
                default_config = {
                    cmd = { "pyrefly", "lsp" },
                    filetypes = { "python" },
                    root_dir = lspconfig.util.root_pattern(
                        "pyproject.toml",
                        "setup.py",
                        "setup.cfg",
                        "requirements.txt",
                        "Pipfile",
                        ".git"
                    ),
                    settings = {},
                },
            }
        end

        -- Change diagnostic symbols in sign column
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- LSP keymaps (applied on attach)
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }

                -- LSP keybindings
                opts.desc = "Show LSP references"
                keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

                opts.desc = "Show LSP implementations"
                keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

                opts.desc = "See available code actions"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts)

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
            end,
        })

        -- Configure lua_ls for Neovim development
        lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                },
            },
        })

        -- Configure other servers with default settings
        local servers = {
            "ts_ls",
            "html",
            "cssls",
            "tailwindcss",
            "jsonls",
            "yamlls",
            "bashls",
            "marksman",
            "eslint",
            "prismals",
        }

        for _, server in ipairs(servers) do
            -- Only setup if the server config exists (Mason has installed it)
            local ok, _ = pcall(function()
                lspconfig[server].setup({
                    capabilities = capabilities,
                })
            end)
            if not ok then
                vim.notify(
                    string.format("LSP server '%s' not available yet. Install via :Mason", server),
                    vim.log.levels.WARN
                )
            end
        end

        -- Configure pyrefly (installed globally via homebrew/cargo)
        local pyrefly_ok, _ = pcall(function()
            lspconfig["pyrefly"].setup({
                capabilities = capabilities,
                settings = {
                    pyrefly = {
                        displayTypeErrors = "force-on",
                    },
                },
            })
        end)
        if not pyrefly_ok then
            vim.notify("pyrefly LSP not available. Ensure 'pyrefly' is installed globally.", vim.log.levels.WARN)
        end

        -- Configure svelte with special on_attach
        pcall(function()
            lspconfig["svelte"].setup({
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePost", {
                        pattern = { "*.js", "*.ts" },
                        callback = function(ctx)
                            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                        end,
                    })
                end,
            })
        end)

        -- Configure graphql with custom filetypes
        pcall(function()
            lspconfig["graphql"].setup({
                capabilities = capabilities,
                filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
            })
        end)

        -- Configure emmet_ls with custom filetypes
        pcall(function()
            lspconfig["emmet_ls"].setup({
                capabilities = capabilities,
                filetypes = {
                    "html",
                    "typescriptreact",
                    "javascriptreact",
                    "css",
                    "sass",
                    "scss",
                    "less",
                    "svelte",
                },
            })
        end)
    end,
}
