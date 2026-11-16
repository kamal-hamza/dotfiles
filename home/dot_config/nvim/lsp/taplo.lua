--- @type vim.lsp.Config
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = {
    '.taplo.toml',
    'taplo.toml',
    '.git',
  },
  workspace_required = false,
  single_file_support = true,
}
