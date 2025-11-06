-- Go project-specific plugins
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "go", "gomod" },
    cond = function()
      return require("utils.project").check_project_condition("go")
    end,
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      lsp_cfg = false, -- We handle LSP through mason-lspconfig
      lsp_keymaps = false, -- We use our own keymaps
      dap_debug = true,
      dap_debug_gui = true,
    },
    config = function(_, opts)
      require("go").setup(opts)
      
      -- Format on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    cond = function()
      return require("utils.project").check_project_condition("go")
    end,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-go",
    },
    cond = function()
      return require("utils.project").check_project_condition("go")
    end,
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      table.insert(opts.adapters, require("neotest-go"))
    end,
  },
}
