-- =============================================================================
-- telescope.nvim — fuzzy finder
-- https://github.com/nvim-telescope/telescope.nvim
-- =============================================================================

local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        -- Horizontal splits
        ["<C-j>"] = actions.select_horizontal,
        ["<C-k>"] = actions.select_horizontal,

        -- Vertical splits
        ["<C-h>"] = actions.select_vertical,
        ["<C-l>"] = actions.select_vertical,

        -- List navigation
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
      },
    },
  },
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace Symbols" })
