-- Python project-specific plugins
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end
      vim.list_extend(opts.ensure_installed, { "python", "ninja", "rst", "toml" })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { 
      "mfussenegger/nvim-dap",
      "williamboman/mason.nvim"
    },
    ft = "python",
    cond = function()
      local ok = pcall(require, "utils.project")
      if not ok then return true end
      return require("utils.project").check_project_condition("python")
    end,
    config = function()
      -- Ensure nvim-dap is loaded first
      local ok, dap = pcall(require, "dap")
      if not ok then
        vim.notify("nvim-dap not found. Please ensure it's installed.", vim.log.levels.ERROR)
        return
      end

      local python_path = vim.fn.exepath("python3") or vim.fn.exepath("python")

      -- Try to find debugpy installed via mason
      local has_mason, mason_registry = pcall(require, "mason-registry")
      if has_mason and mason_registry.is_installed("debugpy") then
        local install_dir = vim.fn.stdpath("data") .. "/mason/packages/debugpy"
        local debugpy_python = install_dir .. "/venv/bin/python"
        if vim.fn.filereadable(debugpy_python) == 1 then
          python_path = debugpy_python
        end
      end

      -- Fallback: Check for virtual environment
      if python_path == vim.fn.exepath("python3") or python_path == vim.fn.exepath("python") then
        if vim.env.VIRTUAL_ENV then
          local venv_python = vim.env.VIRTUAL_ENV .. "/bin/python"
          if vim.fn.filereadable(venv_python) == 1 then
            python_path = venv_python
          end
        elseif vim.fn.isdirectory(".venv") == 1 then
          local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
          if vim.fn.filereadable(venv_python) == 1 then
            python_path = venv_python
          end
        elseif vim.fn.isdirectory("venv") == 1 then
          local venv_python = vim.fn.getcwd() .. "/venv/bin/python"
          if vim.fn.filereadable(venv_python) == 1 then
            python_path = venv_python
          end
        end
      end

      require("dap-python").setup(python_path)
      require('dap-python').test_runner = 'pytest'

      -- Python-specific DAP configurations
      if not dap.configurations.python then
        dap.configurations.python = {}
      end

      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Launch file with arguments',
        program = '${file}',
        args = function()
          local args_string = vim.fn.input('Arguments: ')
          return vim.split(args_string, " +")
        end,
        console = 'integratedTerminal',
      })
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
      local ok = pcall(require, "utils.project")
      if not ok then return true end
      return require("utils.project").check_project_condition("python")
    end,
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      auto_refresh = true,
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
      local ok = pcall(require, "utils.project")
      if not ok then return true end
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
