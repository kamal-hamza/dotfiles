-- plugins loading
vim.pack.add({
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/neogitorg/neogit",
  { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.x") },
  "https://github.com/rebelot/heirline.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
})

-- nvim autopairs
local autopairs = require("nvim-autopairs")
autopairs.setup()

-- oil nvim
local oil = require("oil")
oil.setup()
vim.keymap.set("n", "<leader>ee", function() oil.open() end, { desc = "Open Oil" })

-- nvim telescope
local telescope = require("telescope")
local actions = require("telescope.actions")
telescope.setup({
  defaults = {
    mappings = {
      i = {
        -- Horizontal Splits
        ["<C-j>"] = actions.select_horizontal,
        ["<C-k>"] = actions.select_horizontal, -- Mapping both for comfort

        -- Vertical Splits
        ["<C-h>"] = actions.select_vertical,
        ["<C-l>"] = actions.select_vertical,

        -- If you still want to navigate the list, use Ctrl+n and Ctrl+p
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
      },
    },
  },
})
vim.keymap.set("n", "<leader>ff", function() require('telescope.builtin').find_files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function() require('telescope.builtin').live_grep() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, { desc = "Document Symbols File" })
vim.keymap.set("n", "<leader>fS", function() require("telescope.builtin").lsp_workspace_symbols() end, { desc = "Document Symbols Workspacek"})
vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end, { desc = "Live Grep"})

-- nvim treesitter
local treesitter = require("nvim-treesitter")
treesitter.setup({
  install_dir = vim.fn.stdpath('data') .. '/site'
})
treesitter.install({
  "lua", "python", "rust", "zig", "typescript", "javascript", "c", "cpp"
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "lua", "python", "rust", "zig", "typescript", "javascript", "c", "cpp", "h" },
  callback = function()
    vim.treesitter.start()
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- conform nvim
local conform = require("conform")
-- Configuration is now in formatter.lua

-- trouble nvim
local trouble = require("trouble")
trouble.setup()
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics List" })

-- nvim surround
require("nvim-surround").setup()

-- theme - load and setup dark theme
require("dark").setup({
  theme = "dark",
})
require("dark").load("dark")
