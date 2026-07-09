-- =============================================================================
-- smear-cursor.nvim — animated cursor movement
-- https://github.com/sphamba/smear-cursor.nvim
-- =============================================================================

require("smear_cursor").setup({
  stiffness = 0.8,
  trailing_stiffness = 0.5,
  distance_stop_animating = 0.5,
  smear_between_buffers = true,
  smear_between_neighbor_lines = true,
  scroll_buffer_space = true,
  smear_insert_mode = true,
})
