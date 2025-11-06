return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Disable default tab mapping since we use blink.cmp
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      -- Accept copilot suggestion with Alt+Enter or Ctrl+J
      vim.keymap.set('i', '<M-CR>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      
      -- Navigate between suggestions
      vim.keymap.set('i', '<M-]>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<M-[>', '<Plug>(copilot-previous)')
      vim.keymap.set('i', '<M-\\>', '<Plug>(copilot-suggest)')
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      debug = false,
      show_help = "yes",
      prompts = {
        Explain = "Explain how this code works.",
        Review = "Review this code for potential improvements.",
        Tests = "Write tests for this code.",
        Refactor = "Refactor this code to improve its clarity and readability.",
        FixCode = "Fix the code to make it work as intended.",
        FixError = "Explain the error and suggest fixes.",
        BetterNamings = "Provide better names for variables and functions.",
        Documentation = "Write documentation for this code.",
        SwaggerApiDocs = "Write swagger API documentation for this code.",
        SwaggerJsDocs = "Write swagger JSDoc annotations for this code.",
        Summarize = "Summarize the selected code.",
        Spelling = "Correct any spelling errors in the text.",
        Wording = "Improve the wording in the text.",
        Concise = "Make the text more concise.",
      },
      window = {
        layout = 'float',
        width = 0.8,
        height = 0.8,
        border = 'rounded',
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)

      -- Inline assist function (matches Zed's inline assist)
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = require("CopilotChat.select").visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- Quick chat function
      vim.api.nvim_create_user_command("CopilotChatQuick", function(args)
        local input = args.args
        if input == "" then
          input = vim.fn.input("Quick Chat: ")
        end
        if input ~= "" then
          chat.ask(input, { selection = require("CopilotChat.select").buffer })
        end
      end, { nargs = "*" })
    end,
    event = "VeryLazy",
  },
}
