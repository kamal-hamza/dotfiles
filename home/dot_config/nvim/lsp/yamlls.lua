--- @type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = 'yaml-language-server'
    if (config or {}).root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, '--stdio' }, dispatchers)
  end,
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab', 'yaml.helm-values' },
  root_markers = { '.git' },
  workspace_required = false,
  single_file_support = true,
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = true },
      schemas = {
        ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        ['https://json.schemastore.org/github-action.json'] = { '/.github/actions/*/action.yml', '/.github/actions/*/action.yaml' },
      },
    },
  },
  -- formatting is disabled by default upstream; force the capability on so
  -- `:Format` (conform's lsp_format fallback) and LspAttach checks see it
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = true
  end,
}
