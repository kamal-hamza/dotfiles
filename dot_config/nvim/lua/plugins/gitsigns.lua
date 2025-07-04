return {
  "lewis6991/gitsigns.nvim",
  event = "BufEnter",
  config = function()
    local gitsigns = require("gitsigns")

    gitsigns.setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { "‾" },
        changedelete = { text = "≃" },
        untracked = { text = "?" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { "‾" },
        changedelete = { text = "≃" },
        untracked = { text = "?" },
      },
    })
  end,
}
