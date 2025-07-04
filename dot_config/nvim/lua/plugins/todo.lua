return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    "<leader>tqf"
  },
  config = function()
    local todo_comments = require("todo-comments")
    todo_comments.setup({
      signs = true,
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
        },
        TODO = {
          icon = " ",
          color = "info",
        },
        HACK = {
          icon = " ",
          color = "warning",
        },
        WARN = {
          icon = " ",
          color = "warning",
          alt = { "WARNING", "XXX" },
        },
        PERF = {
          icon = " ",
          alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
        },
        NOTE = {
          icon = " ",
          color = "hint",
          alt = { "INFO" },
        },
        TEST = {
          icon = "⏲ ",
          color = "test",
          alt = { "TESTING", "PASSED", "FAILED" },
        },
      },
      merge_keywords = true,
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },

      vim.keymap.set("n", "<leader>tqf", ":TodoQuickFix<CR>", { desc = "Todo Quick Fix List" })
    })
  end,
}
