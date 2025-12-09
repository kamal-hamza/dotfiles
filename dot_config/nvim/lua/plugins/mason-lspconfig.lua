return {
    -- Mason: Package manager for LSP servers, formatters, linters, etc.
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    },
                    border = "rounded",
                },
                max_concurrent_installers = 10,
            })
        end
    },

    -- Mason Tool Installer: Automatically install formatters, linters, DAPs, etc.
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                -- List of tools to ensure are installed
                ensure_installed = {
                    -- Formatters
                    "stylua",       -- Lua
                    "prettier",     -- JS/TS/JSON/YAML/Markdown/CSS/HTML
                    "prettierd",    -- Faster prettier
                    "ruff",         -- Python (formatting + linting)
                    "goimports",    -- Go imports (includes formatting)
                    "clang-format", -- C/C++
                    "csharpier",    -- C#
                    "shfmt",        -- Shell
                    "taplo",        -- TOML

                    -- Linters
                    "eslint_d",     -- JS/TS
                    "markdownlint", -- Markdown
                    "hadolint",     -- Dockerfile
                    "yamllint",     -- YAML
                    "shellcheck",   -- Shell

                    -- DAP (Debug Adapters)
                    "debugpy", -- Python
                },

                -- Auto-update tools (only when manually running :MasonToolsUpdate)
                auto_update = false,

                -- Run automatically on startup
                run_on_start = true,

                -- Delay before starting installation (ms)
                start_delay = 3000,

                -- Only run every N hours (prevents constant updates)
                debounce_hours = 12,

                -- Enable integrations
                integrations = {
                    ['mason-lspconfig'] = false,
                    ['mason-null-ls'] = false,
                    ['mason-nvim-dap'] = false,
                },
            })
        end,
    },

    -- Mason LSP Config: Bridge between mason and lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            local lspconfig = require("lspconfig")
            local Lsp = require("utils.lsp")

            -- Suppress the workspace/diagnostic/refresh MethodNotFound error
            vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
                return vim.NIL
            end

            -- Setup mason-lspconfig
            -- automatic_installation is disabled to prevent unwanted servers (like ruff LSP) from auto-installing
            mason_lspconfig.setup({
                automatic_installation = false,
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "ts_ls",         -- TypeScript/JavaScript
                    "jsonls",        -- JSON
                    "html",          -- HTML
                    "cssls",         -- CSS
                    "eslint",        -- ESLint
                    -- NOTE: pyright removed - using pyrefly instead
                    "clangd",        -- C/C++
                    "rust_analyzer", -- Rust
                    "gopls",         -- Go
                    "yamlls",        -- YAML
                    "bashls",        -- Bash
                    "marksman",      -- Markdown
                },
            })

            -- Use native Neovim completion capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            -- Native completion is enabled in on_attach via vim.lsp.completion.enable()

            -- Default config for all servers
            local default_config = {
                capabilities = capabilities,
                on_attach = Lsp.on_attach,
            }

            -- Server-specific configurations
            local server_configs = {
                -- Lua Language Server
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = "LuaJIT" },
                            diagnostics = { globals = { "vim" } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = { enable = false },
                            format = { enable = false }, -- Use stylua instead
                        },
                    },
                },

                -- TypeScript/JavaScript
                ts_ls = {
                    settings = {
                        typescript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "literals",
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                        javascript = {
                            inlayHints = {
                                includeInlayParameterNameHints = "all",
                                includeInlayVariableTypeHints = true,
                                includeInlayFunctionLikeReturnTypeHints = true,
                                includeInlayEnumMemberValueHints = true,
                            },
                        },
                    },
                },

                -- JSON with SchemaStore
                jsonls = {
                    settings = {
                        json = {
                            schemas = require("schemastore").json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },

                -- C/C++ (Clangd)
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },

                -- Rust Analyzer
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                runBuildScripts = true,
                            },
                            checkOnSave = {
                                allFeatures = true,
                                command = "clippy",
                                extraArgs = { "--no-deps" },
                            },
                            procMacro = { enable = true },
                        },
                    },
                },

                -- Go (gopls)
                gopls = {
                    settings = {
                        gopls = {
                            analyses = { unusedparams = true },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },

                -- C# (OmniSharp)
                omnisharp = {
                    enable_import_completion = true,
                    organize_imports_on_format = true,
                    enable_roslyn_analyzers = true,
                },
            }

            -- Setup each installed LSP server
            -- We manually loop through installed servers instead of using setup_handlers
            -- to have explicit control over which servers get configured
            for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
                -- Skip pyright - we use pyrefly for Python
                if server_name == "pyright" then
                    goto continue
                end

                -- Skip ruff LSP - we only want ruff as a linter/formatter via nvim-lint and conform
                -- Ruff LSP doesn't provide full language server features (no completion, hover, etc.)
                if server_name == "ruff" or server_name == "ruff_lsp" then
                    goto continue
                end

                local config = vim.tbl_deep_extend(
                    "force",
                    default_config,
                    server_configs[server_name] or {}
                )
                lspconfig[server_name].setup(config)

                ::continue::
            end

            -- Setup pyrefly as THE Python LSP (not pyright)
            local pyrefly_cmd = vim.fn.exepath("pyrefly")
            if pyrefly_cmd ~= "" then
                -- Register pyrefly as a custom server
                local configs = require('lspconfig.configs')
                if not configs.pyrefly then
                    configs.pyrefly = {
                        default_config = {
                            cmd = { pyrefly_cmd, "lsp" },
                            filetypes = { "python" },
                            root_dir = lspconfig.util.root_pattern(
                                "pyproject.toml",
                                "setup.py",
                                "setup.cfg",
                                "requirements.txt",
                                "Pipfile",
                                ".git"
                            ),
                        },
                    }
                end
                lspconfig.pyrefly.setup(vim.tbl_deep_extend("force", default_config, {
                    settings = {
                        pyrefly = {
                            displayTypeErrors = "force-on",
                        },
                    },
                }))
            else
                -- Fallback to pyright only if pyrefly is not installed
                vim.notify("pyrefly not found, install it with: cargo install pyrefly", vim.log.levels.WARN)

                lspconfig.pyright.setup(vim.tbl_deep_extend("force", default_config, {
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                            },
                        },
                    },
                }))
            end

            -- Explicitly prevent ruff LSP from attaching to Python files
            -- We only want ruff as a linter/formatter, not as an LSP server
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "ruff" then
                        vim.lsp.stop_client(client.id)
                        vim.notify("Stopped ruff LSP - using pyrefly for Python instead", vim.log.levels.INFO)
                    end
                end,
            })
        end,
    },

    -- SchemaStore for JSON schemas
    {
        "b0o/schemastore.nvim",
        lazy = true,
    },
}
