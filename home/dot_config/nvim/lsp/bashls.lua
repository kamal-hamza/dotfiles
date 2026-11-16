--- @type vim.lsp.Config
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
  workspace_required = false,
  single_file_support = true,
  settings = {
    bashIde = {
      -- upstream default glob is recursive from the workspace root, which is
      -- slow/unsafe when opening a file directly under $HOME; scope it down
      globPattern = '*@(.sh|.inc|.bash|.command)',
    },
  },
}
