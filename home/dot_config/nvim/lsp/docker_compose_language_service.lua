--- @type vim.lsp.Config
return {
  cmd = { 'docker-compose-langserver', '--stdio' },
  -- requires filetype "yaml.docker-compose", set via vim.filetype.add in
  -- lua/hkamal/filetype.lua since neovim has no builtin detection for it
  filetypes = { 'yaml.docker-compose' },
  root_markers = { 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml', '.git' },
  workspace_required = false,
  single_file_support = true,
}
