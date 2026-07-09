-- =============================================================================
-- undotree — visualize and navigate undo history
-- https://github.com/mbbill/undotree
-- =============================================================================

-- Show diff in the bottom panel
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_WindowLayout = 2  -- tree on left, diff below

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })
