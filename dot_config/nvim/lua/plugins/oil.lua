-- =============================================================================
-- oil.nvim — file explorer as a buffer
-- https://github.com/stevearc/oil.nvim
-- =============================================================================

local oil = require("oil")

oil.setup()

vim.keymap.set("n", "<leader>ee", function()
  oil.open()
end, { desc = "Open Oil" })
