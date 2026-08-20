-- requires `pwsh` on PATH, same as lsp/powershell_es.lua; pses_bundle_path
-- defaults to the mason install dir shared with the LSP
vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/m00qek/baleia.nvim",
    "https://github.com/Willem-J-an/nvim-dap-powershell",
})

-- errors hard if the mason package isn't installed yet (e.g. first launch,
-- before mason-tool-installer finishes downloading it in the background)
local bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services")
if vim.uv.fs_stat(bundle_path) then
    require("dap-powershell").setup()
end
