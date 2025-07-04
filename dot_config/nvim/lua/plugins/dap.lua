return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    -- setup mason
    require("mason").setup()

    -- dap ui setup
    local dap = require("dap")
    local dapui = require("dapui")
    local mason_nvim_dap = require("mason-nvim-dap")
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
