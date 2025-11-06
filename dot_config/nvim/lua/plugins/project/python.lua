-- Python project-specific plugins
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "python", "ninja", "rst" } },
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python",
    cond = function()
      return require("utils.project").check_project_condition("python")
    end,
    config = function()
      -- Try to find a python executable in common locations
      local python_path = vim.fn.exepath("python3") or vim.fn.exepath("python")
      
      -- Check for virtual environment
      if vim.env.VIRTUAL_ENV then
        python_path = vim.env.VIRTUAL_ENV .. "/bin/python"
      elseif vim.fn.isdirectory(".venv") == 1 then
        python_path = vim.fn.getcwd() .. "/.venv/bin/python"
      elseif vim.fn.isdirectory("venv") == 1 then
        python_path = vim.fn.getcwd() .. "/venv/bin/python"
      end
      
      require("dap-python").setup(python_path)
      require('dap-python').test_runner = 'pytest'
    end
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python"
    },
    cond = function()
      return require("utils.project").check_project_condition("python")
    end,
    opts = {
      name = { "venv", ".venv", "env", ".env" },
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Select Cached VirtualEnv" },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    cond = function()
      return require("utils.project").check_project_condition("python")
    end,
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      table.insert(opts.adapters, require("neotest-python")({
        dap = { justMyCode = false },
        args = { "--log-level", "DEBUG", "--quiet" },
        runner = "pytest",
      }))
    end,
  },
}
