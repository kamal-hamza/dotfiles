-- adapted from nvim-lspconfig's lsp/gopls.lua: resolves GOROOT/GOMODCACHE so
-- that opening stdlib or dependency source (e.g. via "gd") reuses the running
-- gopls client instead of failing to find a workspace root for it
local mod_cache = nil
local std_lib = nil

local function identify_go_dir(envvar_id, custom_subdir, on_complete)
  vim.system({ 'go', 'env', envvar_id }, { text = true }, function(output)
    local res = vim.trim(output.stdout or '')
    if output.code == 0 and res ~= '' then
      on_complete((custom_subdir and res .. custom_subdir) or res)
    else
      on_complete(nil)
    end
  end)
end

local function get_std_lib_dir()
  if std_lib and std_lib ~= '' then
    return std_lib
  end
  identify_go_dir('GOROOT', '/src', function(dir)
    if dir then
      std_lib = dir
    end
  end)
  return std_lib
end

local function get_mod_cache_dir()
  if mod_cache and mod_cache ~= '' then
    return mod_cache
  end
  identify_go_dir('GOMODCACHE', nil, function(dir)
    if dir then
      mod_cache = dir
    end
  end)
  return mod_cache
end

local function get_root_dir(fname)
  if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
    local clients = vim.lsp.get_clients({ name = 'gopls' })
    if #clients > 0 then
      return clients[#clients].config.root_dir
    end
  end
  if std_lib and fname:sub(1, #std_lib) == std_lib then
    local clients = vim.lsp.get_clients({ name = 'gopls' })
    if #clients > 0 then
      return clients[#clients].config.root_dir
    end
  end
  return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
end

--- @type vim.lsp.Config
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    get_mod_cache_dir()
    get_std_lib_dir()
    on_dir(get_root_dir(fname))
  end,
  settings = {
    gopls = {
      semanticTokens = true,
      gofumpt = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
