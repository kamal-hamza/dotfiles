-- Treesitter Context - Shows context of current function/class at top of window
-- Inspired by nikolovlazar's dotfiles, adapted for Soft Focus theme

return {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    enabled = false,
    opts = {
        -- Enable/disable context
        enable = true,

        -- Maximum number of lines to show for context
        max_lines = 3,

        -- Minimum number of lines to trigger context
        min_window_height = 0,

        -- Line used to calculate context. Choices: 'cursor', 'topline'
        line_numbers = true,
        multiline_threshold = 20,

        -- Maximum number of lines to collapse for a single context
        trim_scope = 'outer',

        -- Which context lines to discard if `max_lines` is exceeded
        mode = 'cursor',

        -- Separator between context and content
        separator = nil,

        -- Z-index of the context window
        zindex = 20,

        -- (fun(buf: integer): boolean) return false to disable attach
        on_attach = nil,
    },
    config = function(_, opts)
        local ts_context = require("treesitter-context")
        ts_context.setup(opts)

        -- Apply Soft Focus theme colors
        local function apply_context_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}

            -- Default colors for dark theme
            local bg_elevated = colors.bg_elevated or "#1a1a1a"
            local fg = colors.fg or "#f5f5f5"
            local border = colors.border or "#333333"
            local blue = colors.blue or "#448cbb"

            -- Context background slightly different from main background
            vim.api.nvim_set_hl(0, "TreesitterContext", {
                bg = bg_elevated,
                fg = fg,
            })

            -- Context line numbers
            vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", {
                fg = blue,
                bg = bg_elevated,
            })

            -- Separator line (if enabled)
            vim.api.nvim_set_hl(0, "TreesitterContextSeparator", {
                fg = border,
            })

            -- Bottom border
            vim.api.nvim_set_hl(0, "TreesitterContextBottom", {
                underline = true,
                sp = border,
            })
        end

        -- Apply highlights on startup
        apply_context_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_context_highlights,
        })

        -- Toggle function
        local context_enabled = true
        local function toggle_context()
            if context_enabled then
                ts_context.disable()
                vim.notify("Treesitter Context: Disabled", vim.log.levels.INFO)
                context_enabled = false
            else
                ts_context.enable()
                vim.notify("Treesitter Context: Enabled", vim.log.levels.INFO)
                context_enabled = true
            end
        end

        -- Keybinding to toggle context
        vim.keymap.set("n", "<leader>ut", toggle_context, {
            desc = "Toggle Treesitter Context",
            silent = true,
        })

        -- Go to context
        vim.keymap.set("n", "[c", function()
            ts_context.go_to_context(vim.v.count1)
        end, {
            silent = true,
            desc = "Jump to context",
        })
    end,
}
