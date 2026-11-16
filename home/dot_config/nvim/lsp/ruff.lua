--- @type vim.lsp.Config
return {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    workspace_required = false,
    single_file_support = true,
    on_attach = function(client)
        -- defer hover to pyrefly; ruff only handles lint diagnostics + code actions
        client.server_capabilities.hoverProvider = false
    end,
}
