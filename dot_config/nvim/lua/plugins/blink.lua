return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    "mgalliou/blink-cmp-tmux",
    "bydlw98/blink-cmp-env",
    'nvim-lua/plenary.nvim',
    "tailwind-tools",
    "onsails/lspkind-nvim",
    "echasnovski/mini.icons",
  },
  version = '1.*',
  opts = {
    keymap = {
      preset = 'default',
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    },
    
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
      kind_icons = {
        Text = '󰉿',
        Method = '󰊕',
        Function = '󰊕',
        Constructor = '󰒓',
        Field = '󰜢',
        Variable = '󰀫',
        Class = '󰠱',
        Interface = '󰠱',
        Module = '󰏗',
        Property = '󰜢',
        Unit = '󰪚',
        Value = '󰎠',
        Enum = '󰦨',
        Keyword = '󰻾',
        Snippet = '󰩫',
        Color = '󰏘',
        File = '󰈔',
        Reference = '󰬲',
        Folder = '󰉋',
        EnumMember = '󰦨',
        Constant = '󰏿',
        Struct = '󰆼',
        Event = '󱐋',
        Operator = '󰪚',
        TypeParameter = '󰬛',
      },
    },
    
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        treesitter_highlighting = true,
        window = {
          max_width = 80,
          max_height = 20,
          border = 'rounded',
          winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
        },
      },
      menu = {
        border = 'rounded',
        winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
        max_height = 15,
        draw = {
          columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            },
            
            kind = {
              text = function(ctx) return '  ' .. ctx.kind .. '  ' end,
              highlight = function(ctx)
                return 'BlinkCmpKind' .. ctx.kind
              end,
            },
            
            label = {
              width = { fill = true, max = 60 },
              text = function(ctx) return ctx.label .. ctx.label_detail end,
              highlight = function(ctx)
                return ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel'
              end,
            },
            
            label_description = {
              width = { max = 30 },
              text = function(ctx) return ctx.label_description end,
              highlight = 'BlinkCmpLabelDescription',
            },
          },
        },
      },
      ghost_text = {
        enabled = true,
      },
    },
    
    signature = {
      enabled = true,
      window = {
        border = 'rounded',
        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      },
    },
    
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'tmux' },
      providers = {
        tmux = {
          module = "blink-cmp-tmux",
          name = "tmux",
          opts = {
            all_panes = false,
            capture_history = false,
            triggered_only = false,
            trigger_chars = { "." }
          },
        },
      },
    },
  },
  
  config = function(_, opts)
    require('blink.cmp').setup(opts)
    
    -- Get colors from current theme (theme is already loaded in init.lua)
    local theme_name = vim.g.colors_name or "soft-focus-dark"
    local theme_module = "plugins.themes." .. theme_name
    local has_theme, theme = pcall(require, theme_module)
    
    if not has_theme then
      vim.notify("Could not load theme colors for blink.cmp: " .. theme_name, vim.log.levels.WARN)
      return
    end
    
    -- Get the color table from theme
    local colors = theme.colors or {}
    
    -- Fallback colors if theme doesn't provide them
    local bg = colors.bg or "#1e1e2e"
    local bg_alt = colors.bg_alt or "#181825"
    local bg_elevated = colors.bg_elevated or "#313244"
    local fg = colors.fg or "#cdd6f4"
    local fg_alt = colors.fg_alt or "#bac2de"
    local fg_dim = colors.fg_dim or "#6c7086"
    local blue = colors.blue or "#89b4fa"
    local blue_light = colors.blue_light or colors.cyan or "#89dceb"
    local green = colors.green or "#a6e3a1"
    local red = colors.red or "#f38ba8"
    local red_bright = colors.red_bright or colors.red or "#f38ba8"
    local orange = colors.orange or "#fab387"
    local orange_bright = colors.orange_bright or colors.orange or "#f9e2af"
    local purple = colors.purple or "#cba6f7"
    local purple_bright = colors.purple_bright or colors.purple or "#f5c2e7"
    local cyan = colors.cyan or "#94e2d5"
    local border = colors.border or "#45475a"
    
    -- Custom highlight groups for better appearance
    local set_hl = vim.api.nvim_set_hl
    
    -- Menu highlights
    set_hl(0, 'BlinkCmpMenu', { bg = bg, fg = fg })
    set_hl(0, 'BlinkCmpMenuBorder', { bg = bg, fg = blue })
    set_hl(0, 'BlinkCmpMenuSelection', { bg = bg_elevated, fg = fg, bold = true })
    
    -- Documentation highlights
    set_hl(0, 'BlinkCmpDoc', { bg = bg_alt, fg = fg })
    set_hl(0, 'BlinkCmpDocBorder', { bg = bg_alt, fg = blue })
    set_hl(0, 'BlinkCmpDocCursorLine', { bg = bg_elevated })
    
    -- Signature help highlights
    set_hl(0, 'BlinkCmpSignatureHelp', { bg = bg, fg = fg })
    set_hl(0, 'BlinkCmpSignatureHelpBorder', { bg = bg, fg = blue })
    
    -- Label highlights
    set_hl(0, 'BlinkCmpLabel', { fg = fg })
    set_hl(0, 'BlinkCmpLabelDeprecated', { fg = fg_dim, strikethrough = true })
    set_hl(0, 'BlinkCmpLabelDescription', { fg = fg_dim, italic = true })
    
    -- Kind highlights (color-coded by type)
    set_hl(0, 'BlinkCmpKindText', { fg = green })
    set_hl(0, 'BlinkCmpKindMethod', { fg = blue })
    set_hl(0, 'BlinkCmpKindFunction', { fg = blue_light })
    set_hl(0, 'BlinkCmpKindConstructor', { fg = orange })
    set_hl(0, 'BlinkCmpKindField', { fg = cyan })
    set_hl(0, 'BlinkCmpKindVariable', { fg = fg })
    set_hl(0, 'BlinkCmpKindClass', { fg = orange })
    set_hl(0, 'BlinkCmpKindInterface', { fg = orange })
    set_hl(0, 'BlinkCmpKindModule', { fg = purple })
    set_hl(0, 'BlinkCmpKindProperty', { fg = cyan })
    set_hl(0, 'BlinkCmpKindUnit', { fg = green })
    set_hl(0, 'BlinkCmpKindValue', { fg = orange_bright })
    set_hl(0, 'BlinkCmpKindEnum', { fg = orange })
    set_hl(0, 'BlinkCmpKindKeyword', { fg = red_bright })
    set_hl(0, 'BlinkCmpKindSnippet', { fg = purple_bright })
    set_hl(0, 'BlinkCmpKindColor', { fg = orange_bright })
    set_hl(0, 'BlinkCmpKindFile', { fg = blue })
    set_hl(0, 'BlinkCmpKindReference', { fg = cyan })
    set_hl(0, 'BlinkCmpKindFolder', { fg = blue })
    set_hl(0, 'BlinkCmpKindEnumMember', { fg = green })
    set_hl(0, 'BlinkCmpKindConstant', { fg = orange_bright })
    set_hl(0, 'BlinkCmpKindStruct', { fg = orange })
    set_hl(0, 'BlinkCmpKindEvent', { fg = red })
    set_hl(0, 'BlinkCmpKindOperator', { fg = cyan })
    set_hl(0, 'BlinkCmpKindTypeParameter', { fg = orange })
  end,
  
  opts_extend = { "sources.default" }
}
