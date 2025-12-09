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
            "saghen/blink.cmp", -- Ensure blink.cmp loads first
        },
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            local Lsp = require("utils.lsp")

            -- Suppress the workspace/diagnostic/refresh MethodNotFound error
            vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
                return vim.NIL
            end

            -- Setup mason-lspconfig with automatic installation
            mason_lspconfig.setup({
                automatic_installation = true,
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

            -- Get enhanced capabilities from blink.cmp if available
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local has_blink, blink = pcall(require, 'blink.cmp')
            if has_blink then
                capabilities = vim.tbl_deep_extend(
                    'force',
                    capabilities,
                    blink.get_lsp_capabilities()
                )
            end

            -- Helper function to get root directory patterns
            local function root_pattern(...)
                local patterns = { ... }
                return function(fname)
                    local util = require('lspconfig.util')
                    return util.root_pattern(unpack(patterns))(fname) or util.path.dirname(fname)
                end
            end

            -- Server-specific configurations using new vim.lsp.config API
            local server_configs = {
                -- Lua Language Server
                lua_ls = {
                    cmd = { "lua-language-server" },
                    filetypes = { "lua" },
                    root_dir = root_pattern(".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml",
                        "selene.toml", "selene.yml", ".git"),
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
                    cmd = { "typescript-language-server", "--stdio" },
                    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
                    root_dir = root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),
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
                    cmd = { "vscode-json-language-server", "--stdio" },
                    filetypes = { "json", "jsonc" },
                    root_dir = root_pattern(".git"),
                    settings = {
                        json = {
                            schemas = require("schemastore").json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },

                -- HTML
                html = {
                    cmd = { "vscode-html-language-server", "--stdio" },
                    filetypes = { "html" },
                    root_dir = root_pattern(".git"),
                },

                -- CSS
                cssls = {
                    cmd = { "vscode-css-language-server", "--stdio" },
                    filetypes = { "css", "scss", "less" },
                    root_dir = root_pattern(".git"),
                },

                -- ESLint
                eslint = {
                    cmd = { "vscode-eslint-language-server", "--stdio" },
                    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
                    root_dir = root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json", "package.json", ".git"),
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
                    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
                    root_dir = root_pattern(".clangd", ".clang-tidy", ".clang-format", "compile_commands.json",
                        "compile_flags.txt", "configure.ac", ".git"),
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },

                -- Rust Analyzer
                rust_analyzer = {
                    cmd = { "rust-analyzer" },
                    filetypes = { "rust" },
                    root_dir = root_pattern("Cargo.toml", "rust-project.json", ".git"),
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
                    cmd = { "gopls" },
                    filetypes = { "go", "gomod", "gowork", "gotmpl" },
                    root_dir = root_pattern("go.work", "go.mod", ".git"),
                    settings = {
                        gopls = {
                            analyses = { unusedparams = true },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },

                -- YAML
                yamlls = {
                    cmd = { "yaml-language-server", "--stdio" },
                    filetypes = { "yaml", "yaml.docker-compose" },
                    root_dir = root_pattern(".git"),
                },

                -- Bash
                bashls = {
                    cmd = { "bash-language-server", "start" },
                    filetypes = { "sh" },
                    root_dir = root_pattern(".git"),
                },

                -- Markdown
                marksman = {
                    cmd = { "marksman", "server" },
                    filetypes = { "markdown" },
                    root_dir = root_pattern(".git", ".marksman.toml"),
                },

                -- C# (OmniSharp)
                omnisharp = {
                    cmd = { "omnisharp" },
                    filetypes = { "cs" },
                    root_dir = root_pattern("*.sln", "*.csproj", ".git"),
                    enable_import_completion = true,
                    organize_imports_on_format = true,
                    enable_roslyn_analyzers = true,
                },
            }

            -- Setup each LSP server using new vim.lsp.config API
            for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
                -- Skip pyright if it's installed - we're using pyrefly instead
                if server_name ~= "pyright" then
                    local config = server_configs[server_name]

                    if config then
                        -- Use new vim.lsp.config API for Neovim 0.11+
                        -- Server will auto-attach based on filetypes and root_dir
                        vim.lsp.config(server_name, vim.tbl_deep_extend("force", {
                            capabilities = capabilities,
                            on_attach = Lsp.on_attach,
                        }, config))
                    end
                end
            end

            -- Setup pyrefly as THE Python LSP (not pyright)
            local pyrefly_cmd = vim.fn.exepath("pyrefly")
            if pyrefly_cmd ~= "" then
                -- Pyrefly will auto-attach to Python files based on root_dir
                vim.lsp.config("pyrefly", {
                    cmd = { pyrefly_cmd, "lsp" },
                    filetypes = { "python" },
                    root_dir = root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile",
                        ".git"),
                    capabilities = capabilities,
                    on_attach = Lsp.on_attach,
                    settings = {
                        pyrefly = {
                            displayTypeErrors = "force-on",
                        },
                    },
                })
            else
                -- Fallback to pyright only if pyrefly is not installed
                vim.notify("pyrefly not found, install it with: cargo install pyrefly", vim.log.levels.WARN)

                -- Pyright will auto-attach to Python files based on root_dir
                vim.lsp.config("pyright", {
                    cmd = { "pyright-langserver", "--stdio" },
                    filetypes = { "python" },
                    root_dir = root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile",
                        ".git"),
                    capabilities = capabilities,
                    on_attach = Lsp.on_attach,
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                            },
                        },
                    },
                })
            end

            -- Setup newly installed servers automatically
            vim.api.nvim_create_autocmd("User", {
                pattern = "MasonToolsUpdateCompleted",
                callback = function()
                    vim.schedule(function()
                        for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
                            -- Skip pyright - using pyrefly for Python
                            if server_name ~= "pyright" then
                                local config = server_configs[server_name]
                                if config then
                                    -- Check if already configured
                                    local existing = vim.lsp.get_clients({ name = server_name })
                                    if #existing == 0 then
                                        vim.lsp.config(server_name, vim.tbl_deep_extend("force", {
                                            capabilities = capabilities,
                                            on_attach = Lsp.on_attach,
                                        }, config))
                                    end
                                end
                            end
                        end
                    end)
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
