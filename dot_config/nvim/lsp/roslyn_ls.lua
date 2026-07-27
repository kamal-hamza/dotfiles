-- Everything else (cmd, settings, on_init, commands, handlers, on_attach)
-- comes from nvim-lspconfig's bundled roslyn_ls.lua -- vim.lsp.config merges
-- this file with it automatically since they share the same name.
--
-- nvim-lspconfig's root_dir only looks *upward* from the edited file for a
-- .sln/.csproj. This overrides it to fall back to scanning subdirectories of
-- cwd, so it still attaches when nvim is opened above the actual dotnet
-- project.

--- @type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local is_dotnet_project = function(name)
      return name:match('%.sln[x]?$') ~= nil or name:match('%.csproj$') ~= nil
    end

    local root = vim.fs.root(bufnr, is_dotnet_project)
    if root then
      on_dir(root)
      return
    end

    local found = vim.fs.find(is_dotnet_project, {
      path = vim.uv.cwd(),
      upward = false,
      type = 'file',
      limit = 1,
    })[1]

    on_dir(found and vim.fs.dirname(found) or vim.uv.cwd())
  end,
}
