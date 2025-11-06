-- Rust project-specific plugins
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "rust", "toml" } },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    cond = function()
      return require("utils.project").check_project_condition("rust")
    end,
    opts = {
      server = {
        on_attach = function(client, bufnr)
          -- Use default LSP keymaps
          local Lsp = require("utils.lsp")
          Lsp.on_attach(client, bufnr)
          
          -- Rustacean-specific keymaps
          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd.RustLsp("codeAction")
          end, { buffer = bufnr, desc = "LSP: Code Actions (Rust)" })
          
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { buffer = bufnr, desc = "Rust: Debuggables" })
          
          vim.keymap.set("n", "<leader>rr", function()
            vim.cmd.RustLsp("runnables")
          end, { buffer = bufnr, desc = "Rust: Runnables" })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
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
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    cond = function()
      return require("utils.project").check_project_condition("rust")
    end,
    opts = {
      completion = {
        cmp = {
          enabled = true
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "rouge8/neotest-rust",
    },
    cond = function()
      return require("utils.project").check_project_condition("rust")
    end,
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      table.insert(opts.adapters, require("neotest-rust"))
    end,
  },
}
