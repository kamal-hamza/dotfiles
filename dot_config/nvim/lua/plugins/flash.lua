-- =============================================================================
-- flash.nvim — fast jump / search motions
-- https://github.com/folke/flash.nvim
-- =============================================================================

local flash = require("flash")

flash.setup({
  modes = {
    -- Enable flash highlighting during / and ? searches
    search = { enabled = true },
    -- Use flash labels when using f/F/t/T motions
    char = { enabled = true },
  },
})

-- s — jump to any location in the visible window
vim.keymap.set({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash Jump" })

-- S — jump using treesitter node selection
vim.keymap.set({ "n", "x", "o" }, "S", function() flash.treesitter() end, { desc = "Flash Treesitter" })

-- r — remote flash (operator-pending: perform action on remote location)
vim.keymap.set("o", "r", function() flash.remote() end, { desc = "Remote Flash" })

-- R — treesitter search across window
vim.keymap.set({ "o", "x" }, "R", function() flash.treesitter_search() end, { desc = "Treesitter Search" })

-- <C-s> — toggle flash search highlighting inside / search mode
vim.keymap.set("c", "<C-s>", function() flash.toggle() end, { desc = "Toggle Flash Search" })
