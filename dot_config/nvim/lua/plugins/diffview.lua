-- =============================================================================
-- diffview.nvim — tabpage git diff and file history viewer
-- https://github.com/sindrets/diffview.nvim
-- =============================================================================

require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    default = {
      layout = "diff2_horizontal",
    },
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true,
    },
  },
})

-- Open diff against HEAD
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff View" })

-- Open file history for the whole repo
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Git File History (repo)" })

-- Open file history for the current file only
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git File History (file)" })

-- Close diffview
vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Close Diff View" })
