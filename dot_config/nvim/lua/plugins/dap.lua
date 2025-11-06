return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    -- setup mason (if not already done)
    require("mason").setup()

    -- dap ui setup
    local dap = require("dap")
    local dapui = require("dapui")
    local mason_nvim_dap = require("mason-nvim-dap")
    
    -- Setup mason-nvim-dap for automatic DAP adapter installation
    mason_nvim_dap.setup({
      -- Automatically install debug adapters
      automatic_installation = true,
      
      -- Ensure these debug adapters are always installed
      ensure_installed = {
        "python",
        "codelldb",
        "node2",
        "js",
        "bash",
      },
      
      -- Automatic setup handlers for common debug adapters
      handlers = {
        function(config)
          -- Default handler - will be called for all adapters
          mason_nvim_dap.default_setup(config)
        end,
        
        -- Python specific handler
        python = function(config)
          config.adapters = {
            type = "executable",
            command = vim.fn.exepath("python3") or vim.fn.exepath("python"),
            args = {
              "-m",
              "debugpy.adapter",
            },
          }
          mason_nvim_dap.default_setup(config)
        end,
        
        -- C/C++/Rust handler (codelldb)
        codelldb = function(config)
          config.adapters = {
            type = "server",
            port = "${port}",
            executable = {
              command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
              args = { "--port", "${port}" },
            },
          }
          config.configurations = {
            {
              name = "Launch file",
              type = "codelldb",
              request = "launch",
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          }
          mason_nvim_dap.default_setup(config)
        end,
        
        -- Bash debugger
        bash = function(config)
          config.adapters = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
            args = {},
          }
          config.configurations = {
            {
              type = "bash",
              request = "launch",
              name = "Launch file",
              showDebugOutput = true,
              pathBashdb = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
              pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
              trace = true,
              file = "${file}",
              program = "${file}",
              cwd = "${workspaceFolder}",
              pathCat = "cat",
              pathBash = "/bin/bash",
              pathMkfifo = "mkfifo",
              pathPkill = "pkill",
              args = {},
              env = {},
              terminalKind = "integrated",
            },
          }
          mason_nvim_dap.default_setup(config)
        end,
      },
    })
    
    require("dapui").setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- keymaps
    vim.keymap.set('n', '<leader>dc', function() dap.continue() end, { desc = "Debug: Continue" })
    vim.keymap.set('n', '<leader>dn', function() dap.step_over() end, { desc = "Debug: Step Over (Next)" })
    vim.keymap.set('n', '<leader>di', function() dap.step_into() end, { desc = "Debug: Step Into" })
    vim.keymap.set('n', '<leader>do', function() dap.step_out() end, { desc = "Debug: Step Out" })
    vim.keymap.set('n', '<leader>dt', function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end, { desc = "Debug: Open REPL" })
    vim.keymap.set('n', '<leader>dl', function() dap.run_last() end, { desc = "Debug: Run Last" })
    vim.keymap.set('n', '<leader>dq', function() dap.terminate() end, { desc = "Debug: Quit/Terminate" })
  end
}
