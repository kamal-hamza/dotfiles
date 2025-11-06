return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "c_sharp" } },
  },
  {
    "MoaidHathot/dotnet.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    cond = function()
      return require("utils.project").check_project_condition("dotnet")
    end,
    opts = {
      bootstrap = {
        auto_bootstrap = true,
      },
      project_selection = {
        path_display = "filename_first"
      }
    }
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    cond = function()
      return require("utils.project").check_project_condition("dotnet")
    end,
    opts = function(_, opts)
      if not opts.adapters then
        opts.adapters = {}
      end
      table.insert(opts.adapters, require("neotest-dotnet"))
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    cond = function()
      return require("utils.project").check_project_condition("dotnet")
    end,
    opts = function()
      local dap = require("dap")
      
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.adapters.netcoredbg = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }
    end,
  },
}
