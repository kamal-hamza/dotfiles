return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    local keymap = vim.keymap
    local opts = { noremap = true, silent = true }
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_mappings_enabled = 0

    keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<CR>", opts)
    keymap.set("n", "<leader>lv", "<Cmd>VimtexView<CR>", opts)
    keymap.set("n", "<leader>ls", "<Cmd>VimtexStop<CR>", opts)
    keymap.set("n", "<leader>lk", "<Cmd>VimtexCompileClean<CR>", opts)
    keymap.set("n", "<leader>lt", "<Cmd>VimtexTocToggle<CR>", opts)
    keymap.set("n", "<leader>ln", "<Cmd>VimtexErrors<CR>", opts)
  end,
}
