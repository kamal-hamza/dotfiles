vim.pack.add({ "https://github.com/jay-babu/mason-nvim-dap.nvim" })

require("mason-nvim-dap").setup({
    ensure_installed = {
        "codelldb",
        "netcoredbg",
        "debugpy",
        "bash-debug-adapter",
        "delve",
    },
    automatic_installation = true,
    handlers = {},
})
