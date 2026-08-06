vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })

local dap = require("dap")

vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "S", texthl = "DiagnosticOk", linehl = "Visual" })

dap.configurations.rust = require("hkamal.dap.rust")
dap.configurations.c = require("hkamal.dap.c")
dap.configurations.cpp = require("hkamal.dap.cpp")
dap.configurations.cs = require("hkamal.dap.cs")
dap.configurations.python = require("hkamal.dap.python")

local function conditional_breakpoint()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end

vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>dB", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dC", conditional_breakpoint, { desc = "Debug: Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })

vim.api.nvim_create_user_command("DapContinue", dap.continue, { desc = "Debug: Continue" })
vim.api.nvim_create_user_command("StepInto", dap.step_into, { desc = "Debug: Step Into" })
vim.api.nvim_create_user_command("StepOver", dap.step_over, { desc = "Debug: Step Over" })
vim.api.nvim_create_user_command("StepOut", dap.step_out, { desc = "Debug: Step Out" })
vim.api.nvim_create_user_command("DapToggleBreakpoint", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.api.nvim_create_user_command(
    "DapConditionBreakpoint",
    conditional_breakpoint,
    { desc = "Debug: Conditional Breakpoint" }
)
vim.api.nvim_create_user_command("DapToggleRepl", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
vim.api.nvim_create_user_command("DapRunLast", dap.run_last, { desc = "Debug: Run Last" })
vim.api.nvim_create_user_command("DapTerminate", dap.terminate, { desc = "Debug: Terminate" })
