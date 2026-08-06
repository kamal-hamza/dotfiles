vim.pack.add({
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/rcarriga/nvim-dap-ui",
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
    layouts = {
        {
            elements = {
                "console",
                "watches",
            },
            size = 0.25,
            position = "bottom",
        },
    },
})

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

local function eval_under_cursor()
    dapui.eval(nil, { enter = true })
end

vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
vim.keymap.set("n", "<leader>de", eval_under_cursor, { desc = "Debug: Eval Under Cursor" })

vim.api.nvim_create_user_command("DapUiToggle", dapui.toggle, { desc = "Debug: Toggle UI" })
vim.api.nvim_create_user_command("DapEval", eval_under_cursor, { desc = "Debug: Eval Under Cursor" })
