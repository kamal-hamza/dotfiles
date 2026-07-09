-- =============================================================================
-- render-markdown.nvim — rich markdown rendering in the buffer
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- =============================================================================

require("render-markdown").setup({
  -- Only render when the buffer is active
  render_modes = { "n", "c" },
  heading = {
    -- Use block-style background highlights for headings
    enabled = true,
    sign = false,
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
  },
  code = {
    enabled = true,
    sign = false,
    style = "full",      -- highlight the full code block background
    border = "thin",
  },
  bullet = {
    enabled = true,
    icons = { "●", "○", "◆", "◇" },
  },
  checkbox = {
    enabled = true,
    unchecked = { icon = "󰄱 " },
    checked = { icon = "󰱒 " },
  },
  dash = { enabled = true },
  quote = { enabled = true },
  pipe_table = { enabled = true },
  link = { enabled = true },
})
