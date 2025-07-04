local Lsp = require "utils.lsp"
return {
  cmd = { 'clangd', '--background-index' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt' },
  filetypes = { 'c', 'cpp' },
  on_attach = Lsp.on_attach
}
