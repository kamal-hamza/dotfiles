-- =============================================================================
-- Plugin Declarations (centralized)
-- =============================================================================
-- All vim.pack.add calls live here so load order is explicit and easy to audit.

vim.pack.add({
  -- File explorer
  "https://github.com/stevearc/oil.nvim",

  -- Fuzzy finder + dependency
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim",

  -- Editing helpers
  "https://github.com/windwp/nvim-autopairs",
  { src = "https://github.com/kylechui/nvim-surround", version = vim.version.range("4.x") },

  -- Formatting
  "https://github.com/stevearc/conform.nvim",

  -- Diagnostics
  "https://github.com/folke/trouble.nvim",

  -- Git
  "https://github.com/neogitorg/neogit",
  "https://github.com/lewis6991/gitsigns.nvim",

  -- Statusline
  "https://github.com/rebelot/heirline.nvim",

  -- Cursor animation
  "https://github.com/sphamba/smear-cursor.nvim",

  -- Note taking
  { src = "https://github.com/obsidian-nvim/obsidian.nvim", version = vim.version.range("*") },

  -- Code outline / symbol tree
  "https://github.com/hedyhli/outline.nvim",
  "https://github.com/epheien/outline-treesitter-provider.nvim",

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  { src = "https://github.com/saghen/blink.cmp.git", version = vim.version.range("*") },

  -- Navigation
  "https://github.com/folke/flash.nvim",

  -- Markdown rendering
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",

  -- Undo history
  "https://github.com/mbbill/undotree",

  -- Git diff viewer
  "https://github.com/sindrets/diffview.nvim",
})
