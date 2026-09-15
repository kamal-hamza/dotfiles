-- Everything else (cmd, settings, on_init, commands, handlers, on_attach)
-- comes from nvim-lspconfig's bundled roslyn_ls.lua -- vim.lsp.config merges
-- this file with it automatically since they share the same name.
--
-- nvim-lspconfig's root_dir only looks *upward* from the edited file for a
-- .sln/.csproj. This overrides it to fall back to scanning subdirectories of
-- cwd, so it still attaches when nvim is opened above the actual dotnet
-- project.
--
-- The .sln/.slnx and .csproj checks must stay two separate upward passes,
-- not one combined predicate: vim.fs.root() stops at the nearest matching
-- ancestor, and a .csproj is often closer to the edited file than the
-- .sln[x] that actually owns it (e.g. sln in `backend/`, csproj in
-- `backend/src/Api/`). A combined predicate picks the csproj, skips the
-- solution entirely, and Roslyn falls back to loading that project as a
-- standalone/misc file -- which implies SDK-default ImplicitUsings and
-- makes every using directive in the file look unnecessary.
local function is_sln(name)
  return name:match('%.sln[x]?$') ~= nil
end

local function is_csproj(name)
  return name:match('%.csproj$') ~= nil
end

--- @type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, is_sln) or vim.fs.root(bufnr, is_csproj)
    if root then
      on_dir(root)
      return
    end

    local is_dotnet_project = function(name)
      return is_sln(name) or is_csproj(name)
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
