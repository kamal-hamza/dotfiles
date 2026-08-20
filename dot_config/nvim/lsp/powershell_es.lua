-- nvim-lspconfig ships its own lsp/powershell_es.lua (loaded from the plugin
-- dir, later on 'runtimepath' than this file) which builds `cmd` as a
-- function of `bundle_path`, overriding any `cmd` set here; the only thing
-- worth overriding locally is `bundle_path` itself, pointed at mason's
-- install dir. Requires `pwsh` (PowerShell 7+) on PATH.
--- @type vim.lsp.Config
return {
  bundle_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'packages', 'powershell-editor-services'),
  filetypes = { 'ps1', 'psm1', 'psd1' },
  root_markers = { 'PSScriptAnalyzerSettings.psd1', '.git' },
}
