-- =============================================================================
-- obsidian.nvim — Obsidian-style note taking
-- https://github.com/obsidian-nvim/obsidian.nvim
-- =============================================================================

require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "personal",
      path = "~/Code/kamal-hamza.github.io/content/",
    },
  },
})
