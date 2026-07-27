--- @type vim.lsp.Config
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = {
    'Cargo.toml',
    '.git',
  },
  workspace_required = false,
  single_file_support = true,
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
      },
      cargo = {
        allFeatures = true,
      },
    },
  },
}
