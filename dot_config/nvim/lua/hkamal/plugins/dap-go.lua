vim.pack.add({ "https://github.com/leoluz/nvim-dap-go" })

require("dap-go").setup()

vim.keymap.set("n", "<leader>dg", function()
    require("dap-go").debug_test()
end, { desc = "Debug: Go Test (nearest)" })
