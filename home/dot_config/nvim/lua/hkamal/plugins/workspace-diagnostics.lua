vim.pack.add({ "https://github.com/artemave/workspace-diagnostics.nvim" })

require("workspace-diagnostics").setup({})

vim.lsp.config("*", {
    on_attach = function(client, bufnr)
        if client:supports_method("workspace/diagnostic", bufnr) then
            vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
        else
            require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
        end
    end,
})
