local Lsp = require "utils.lsp"

return {
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  on_attach = Lsp.on_attach,
  filetypes = { "cs", "vb" },
  root_dir = function(fname)
    if type(fname) == "number" then
      fname = vim.api.nvim_buf_get_name(fname)
    end
    local root_files = { "*.csproj", "*.sln", ".git" }
    local path = vim.fs.dirname(fname)
    for _, pattern in ipairs(root_files) do
      local found = vim.fs.find(pattern, { upward = true, path = path })[1]
      if found then
        return vim.fs.dirname(found)
      end
    end
    return vim.fn.getcwd()
  end,
  settings = {
    omnisharp = {
      useModernNet = true,
    },
  },
}
