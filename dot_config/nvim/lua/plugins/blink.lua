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
            use_nvim_cmp_as_default = false,
            nerd_font_variant = 'mono',
        },

        completion = {
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false
                }
            },

            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                treesitter_highlighting = true,
                window = {
                    border = 'rounded',
                    winhighlight =
                    'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
                },
            },

            menu = {
                auto_show = true,
                border = 'rounded',
                winhighlight =
                'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
                scrollbar = false,
                draw = {
                    treesitter = { 'lsp' },
                    columns = {
                        { 'kind_icon', 'label', gap = 1 },
                        { 'kind' }
                    },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                                return kind_icon .. ' '
                            end,
                        },
                        label = {
                            width = { fill = true },
                            text = function(ctx)
                                return ctx.label
                            end,
                        },
                        kind = {
                            width = { max = 15 },
                            text = function(ctx)
                                return ctx.kind
                            end,
                        },
                    },
                },
            },

            ghost_text = {
                enabled = false,
            },
        },

        signature = {
            enabled = true,
            window = {
                border = 'single',
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

        -- Get colors from current theme
        local theme_name = vim.g.colors_name or "soft-focus-dark"
        local theme_module = "plugins.themes." .. theme_name
        local has_theme, theme = pcall(require, theme_module)

        local colors
        if has_theme and theme.colors then
            colors = theme.colors
        else
            -- Fallback colors
            colors = {
                bg = "#0a0a0a",
                bg_alt = "#0f0f0f",
                bg_elevated = "#1a1a1a",
                fg = "#e0e0e0",
                fg_alt = "#b0b0b0",
                fg_dim = "#606060",
                blue = "#5f87af",
                cyan = "#5fafaf",
                green = "#87af87",
                orange = "#d7875f",
                purple = "#af87d7",
                red = "#d75f5f",
                comment = "#585858",
            }
        end

        local set_hl = vim.api.nvim_set_hl

        -- Completion menu - native style with theme colors
        set_hl(0, 'BlinkCmpMenu', { bg = colors.bg, fg = colors.fg })
        set_hl(0, 'BlinkCmpMenuBorder', { bg = colors.bg, fg = colors.border })
        set_hl(0, 'BlinkCmpMenuSelection', { bg = colors.cursor_line or colors.bg_elevated, fg = colors.fg, bold = true })

        -- Documentation window
        set_hl(0, 'BlinkCmpDoc', { bg = colors.bg, fg = colors.fg })
        set_hl(0, 'BlinkCmpDocBorder', { bg = colors.bg, fg = colors.border })
        set_hl(0, 'BlinkCmpDocCursorLine', { bg = colors.cursor_line or colors.bg_elevated })

        -- Signature help
        set_hl(0, 'BlinkCmpSignatureHelp', { bg = colors.bg, fg = colors.fg })
        set_hl(0, 'BlinkCmpSignatureHelpBorder', { bg = colors.bg, fg = colors.border })
        set_hl(0, 'BlinkCmpSignatureHelpActiveParameter', { fg = colors.blue_light or colors.blue, bold = true })

        -- Labels and text
        set_hl(0, 'BlinkCmpLabel', { fg = colors.fg })
        set_hl(0, 'BlinkCmpLabelDeprecated', { fg = colors.fg_dim, strikethrough = true })
        set_hl(0, 'BlinkCmpLabelMatch', { fg = colors.blue_light or colors.blue, bold = true })
        set_hl(0, 'BlinkCmpLabelDescription', { fg = colors.fg_dim or colors.comment })
        set_hl(0, 'BlinkCmpLabelDetail', { fg = colors.fg_dim or colors.comment })

        -- Kind column (subtle, not too colorful for native look)
        set_hl(0, 'BlinkCmpKind', { fg = colors.fg_alt })
        set_hl(0, 'BlinkCmpKindText', { fg = colors.fg_alt })
        set_hl(0, 'BlinkCmpKindMethod', { fg = colors.blue })
        set_hl(0, 'BlinkCmpKindFunction', { fg = colors.blue })
        set_hl(0, 'BlinkCmpKindConstructor', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindField', { fg = colors.cyan })
        set_hl(0, 'BlinkCmpKindVariable', { fg = colors.fg_alt })
        set_hl(0, 'BlinkCmpKindClass', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindInterface', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindModule', { fg = colors.purple })
        set_hl(0, 'BlinkCmpKindProperty', { fg = colors.cyan })
        set_hl(0, 'BlinkCmpKindUnit', { fg = colors.green })
        set_hl(0, 'BlinkCmpKindValue', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindEnum', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindKeyword', { fg = colors.red })
        set_hl(0, 'BlinkCmpKindSnippet', { fg = colors.purple })
        set_hl(0, 'BlinkCmpKindColor', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindFile', { fg = colors.blue })
        set_hl(0, 'BlinkCmpKindReference', { fg = colors.cyan })
        set_hl(0, 'BlinkCmpKindFolder', { fg = colors.blue })
        set_hl(0, 'BlinkCmpKindEnumMember', { fg = colors.green })
        set_hl(0, 'BlinkCmpKindConstant', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindStruct', { fg = colors.orange })
        set_hl(0, 'BlinkCmpKindEvent', { fg = colors.red })
        set_hl(0, 'BlinkCmpKindOperator', { fg = colors.cyan })
        set_hl(0, 'BlinkCmpKindTypeParameter', { fg = colors.orange })
    end,

    opts_extend = { "sources.default" }
}
