return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    "mgalliou/blink-cmp-tmux",
    "bydlw98/blink-cmp-env",
    'nvim-lua/plenary.nvim',
    "tailwind-tools",
    "onsails/lspkind-nvim",
  },
  version = '1.*',
  opts = function()
    return {
      formatting = {
        format = require("lspkind").cmp_format({
          before = require("tailwind-tools.cmp").lspkind_format
        }),
      },
    }
  end,
  opts = {
    keymap = {
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = { documentation = { auto_show = false } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'tmux' },
      providers = {
        tmux = {
          module = "blink-cmp-tmux",
          name = "tmux",
          -- default options
          opts = {
            all_panes = false,
            capture_history = false,
            -- only suggest completions from `tmux` if the `trigger_chars` are
            -- used
            triggered_only = false,
            trigger_chars = { "." }
          },
        },
      },

    },
    fuzzy = { implementation = "lua" },
  },
  opts_extend = { "sources.default" }
}
