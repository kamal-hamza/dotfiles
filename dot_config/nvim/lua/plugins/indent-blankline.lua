-- indent-blankline.nvim - Better indentation guides
-- Provides visual guides for indentation levels
-- Adapted for Soft Focus theme

return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    enabled = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        -- Indentation settings
        indent = {
            char = "│",
            tab_char = "│",
            highlight = "IblIndent",
            smart_indent_cap = true,
        },

        -- Whitespace settings
        whitespace = {
            highlight = "IblWhitespace",
            remove_blankline_trail = true,
        },

        -- Scope settings (highlight current code block)
        scope = {
            enabled = true,
            char = "│",
            show_start = true,
            show_end = false,
            show_exact_scope = true,
            injected_languages = true,
            highlight = "IblScope",
            priority = 1024,
            include = {
                node_type = {
                    ["*"] = {
                        "class",
                        "function",
                        "method",
                        "^if",
                        "^while",
                        "^for",
                        "^object",
                        "^table",
                        "block",
                        "arguments",
                    },
                },
            },
        },

        -- Exclude certain filetypes
        exclude = {
            filetypes = {
                "help",
                "alpha",
                "dashboard",
                "neo-tree",
                "Trouble",
                "lazy",
                "mason",
                "notify",
                "toggleterm",
                "lazyterm",
                "snacks_dashboard",
                "snacks_notif",
                "snacks_terminal",
                "snacks_win",
                "oil",
                "TelescopePrompt",
                "TelescopeResults",
            },
            buftypes = {
                "terminal",
                "nofile",
                "quickfix",
                "prompt",
            },
        },
    },
    config = function(_, opts)
        require("ibl").setup(opts)

        -- Apply Soft Focus theme colors
        local function apply_indent_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}

            -- Default colors for dark theme
            local bg = colors.bg or "#050505"
            local fg_dim = colors.fg_dim or "#888888"
            local comment = colors.comment or "#888888"
            local blue = colors.blue or "#448cbb"
            local blue_light = colors.blue_light or "#67b7f5"

            -- Subtle indent guides
            vim.api.nvim_set_hl(0, "IblIndent", {
                fg = "#1a1a1a", -- Very subtle
                nocombine = true,
            })

            -- Slightly more visible for current scope
            vim.api.nvim_set_hl(0, "IblScope", {
                fg = blue,
                nocombine = true,
            })

            -- Whitespace
            vim.api.nvim_set_hl(0, "IblWhitespace", {
                fg = bg,
                nocombine = true,
            })
        end

        -- Apply highlights on startup
        apply_indent_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_indent_highlights,
        })

        -- Add keybinding to toggle indent guides
        vim.keymap.set("n", "<leader>ui", "<cmd>IBLToggle<cr>", {
            desc = "Toggle Indent Guides",
            silent = true,
        })
    end,
}
