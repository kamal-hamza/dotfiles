--- @type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = 'tsgo'
    if (config or {}).root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = {
    'package.json',
    'tsconfig.json',
    'jsconfig.json',
    '.git',
  },
  workspace_required = false,
  single_file_support = true,
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}
