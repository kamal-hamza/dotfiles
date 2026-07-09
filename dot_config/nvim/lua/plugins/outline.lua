-- =============================================================================
-- outline.nvim — code symbol tree / outline sidebar
-- https://github.com/hedyhli/outline.nvim
-- https://github.com/epheien/outline-treesitter-provider.nvim
-- =============================================================================

require("outline").setup({
  providers = {
    priority = { "lsp", "markdown", "norg" },
  },
  symbols = {
    filter = { "String", "Variable", exclude = true },
  },
  outline_window = {
    position = 'left',
    show_cursorline = true,
    hide_cursor = false,
    auto_jump = true,
  },
  symbol_folding = {
    autofold_depth = false,
    auto_unfold = {
      hovered = true,
    },
  },
  preview_window = {
    auto_preview = false,
    live = true,
  },
})
