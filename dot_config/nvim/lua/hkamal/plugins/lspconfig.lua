vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
    "emmylua_ls",
    "tsgo",
    "tailwindcss",
    "pyrefly",
    "rust_analyzer",
    "clangd",
    "taplo",
    "jsonls",
    "roslyn_ls",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = event.buf, desc = "Hover" })
    end,
})
