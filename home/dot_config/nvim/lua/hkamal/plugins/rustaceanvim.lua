-- rustaceanvim manages the rust-analyzer LSP client itself (via ftplugin/rust.lua),
-- so it replaces lsp/rust_analyzer.lua + vim.lsp.enable("rust_analyzer") from lspconfig.lua.
-- vim.g.rustaceanvim must be set before the rust ftplugin runs, so set it before vim.pack.add.
vim.g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                check = { command = "clippy" },
                cargo = { allFeatures = true },
            },
        },
    },
}

vim.pack.add({ "https://github.com/mrcjkb/rustaceanvim" })
