return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local Lsp = require("utils.lsp")

      -- Setup mason-lspconfig
      mason_lspconfig.setup({
        -- Automatically install LSP servers when opening files
        automatic_installation = true,
        
        -- Ensure these LSP servers are always installed
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "jsonls",
          "html",
          "cssls",
          "eslint",
          "pyright",
          "clangd",
          "rust_analyzer",
        },
      })

      -- Default LSP capabilities (for completion, etc.)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      
      -- Enhanced capabilities for blink.cmp
      capabilities = vim.tbl_deep_extend(
        'force',
        capabilities,
        require('blink.cmp').get_lsp_capabilities()
      )

      -- Custom server configurations
      local server_configs = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literals",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = false,
                includeInlayVariableTypeHints = false,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
                showOnAllFunctions = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayParameterNameHints = "all",
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        omnisharp = {
          cmd = { "omnisharp" },
          enable_import_completion = true,
          organize_imports_on_format = true,
          enable_roslyn_analyzers = true,
        },
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
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
      }

      -- Setup LSP servers after mason-lspconfig installs them
      -- Suppress deprecation warning for lspconfig framework during transition period
      local ok, lspconfig = pcall(require, 'lspconfig')
      if not ok then
        vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
        return
      end
      
      -- Setup each server with custom or default config
      local installed_servers = mason_lspconfig.get_installed_servers()
      for _, server_name in ipairs(installed_servers) do
        -- Skip if not a valid LSP server (e.g., formatters like stylua)
        if lspconfig[server_name] and lspconfig[server_name].document_config then
          local config = {
            capabilities = capabilities,
            on_attach = Lsp.on_attach,
          }
          
          -- Merge custom config if it exists
          if server_configs[server_name] then
            config = vim.tbl_deep_extend("force", config, server_configs[server_name])
          end
          
          lspconfig[server_name].setup(config)
        end
      end
    end,
  },
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
}
