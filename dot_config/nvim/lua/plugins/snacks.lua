return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = false }, -- DISABLED
        explorer = { enabled = false },
        indent = { enabled = false },
        input = { enabled = true },
        picker = {
            enabled = false,
            toggles = {
                hidden = { icon = "h", value = true },
            }
        },
        notifier = {
            enabled = true,
            style = "compact",
        },
        quickfile = { enabled = true },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        terminal = { enabled = true },
        words = { enabled = false },
    },
    keys = {
        {
            "<leader>N",
            desc = "Neovim News",
            function()
                Snacks.win({
                    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                    width = 0.6,
                    height = 0.6,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = "yes",
                        statuscolumn = " ",
                        conceallevel = 3,
                    },
                })
            end,
        },
        {
            "<leader>un",
            function() Snacks.notifier.show_history() end,
            desc = "Notification History",
        },
        {
            "<leader>nd",
            function() Snacks.notifier.hide() end,
            desc = "Dismiss All Notifications",
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for := command

                -- Create some toggle mappings
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
                    :map(
                        "<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map(
                    "<leader>ub")
                Snacks.toggle.inlay_hints():map("<leader>uh")
                Snacks.toggle.indent():map("<leader>ug")
                Snacks.toggle.dim():map("<leader>uD")
            end,
        })

        -- Apply Soft Focus theme colors to snacks
        local function apply_snacks_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}
            local bg = colors.bg or "#050505"
            local bg_elevated = colors.bg_elevated or "#1a1a1a"
            local fg = colors.fg or "#f5f5f5"
            local border = colors.border or "#333333"

            -- Snacks notifications
            vim.api.nvim_set_hl(0, "SnacksNotifierInfo", { fg = colors.info or colors.green or "#77aa77", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierWarn", { fg = colors.warn or colors.orange or "#D4B87B", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierError", { fg = colors.error or colors.red or "#C42847", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierDebug", { fg = colors.comment or "#888888", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierTrace", { fg = colors.hint or colors.blue or "#448cbb", bg = bg })

            vim.api.nvim_set_hl(0, "SnacksNotifierIconInfo",
                { fg = colors.info or colors.green or "#77aa77", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierIconWarn",
                { fg = colors.warn or colors.orange or "#D4B87B", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierIconError",
                { fg = colors.error or colors.red or "#C42847", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierIconDebug", { fg = colors.comment or "#888888", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierIconTrace",
                { fg = colors.hint or colors.blue or "#448cbb", bg = bg })

            vim.api.nvim_set_hl(0, "SnacksNotifierTitleInfo",
                { fg = colors.info or colors.green or "#77aa77", bg = bg, bold = true })
            vim.api.nvim_set_hl(0, "SnacksNotifierTitleWarn",
                { fg = colors.warn or colors.orange or "#D4B87B", bg = bg, bold = true })
            vim.api.nvim_set_hl(0, "SnacksNotifierTitleError",
                { fg = colors.error or colors.red or "#C42847", bg = bg, bold = true })
            vim.api.nvim_set_hl(0, "SnacksNotifierTitleDebug",
                { fg = colors.comment or "#888888", bg = bg, bold = true })
            vim.api.nvim_set_hl(0, "SnacksNotifierTitleTrace",
                { fg = colors.hint or colors.blue or "#448cbb", bg = bg, bold = true })

            vim.api.nvim_set_hl(0, "SnacksNotifierBorderInfo",
                { fg = colors.info or colors.green or "#77aa77", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierBorderWarn",
                { fg = colors.warn or colors.orange or "#D4B87B", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierBorderError",
                { fg = colors.error or colors.red or "#C42847", bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierBorderDebug", { fg = border, bg = bg })
            vim.api.nvim_set_hl(0, "SnacksNotifierBorderTrace",
                { fg = colors.hint or colors.blue or "#448cbb", bg = bg })

            -- Snacks input
            vim.api.nvim_set_hl(0, "SnacksInputNormal", { bg = bg, fg = fg })
            vim.api.nvim_set_hl(0, "SnacksInputBorder", { bg = bg, fg = border })
            vim.api.nvim_set_hl(0, "SnacksInputTitle", { bg = bg, fg = colors.blue_light or "#67b7f5", bold = true })

            -- Snacks other windows
            vim.api.nvim_set_hl(0, "SnacksNormal", { bg = bg, fg = fg })
            vim.api.nvim_set_hl(0, "SnacksBorder", { bg = bg, fg = border })
            vim.api.nvim_set_hl(0, "SnacksTitle", { bg = bg, fg = colors.blue_light or "#67b7f5", bold = true })
        end

        -- Apply highlights on startup
        vim.schedule(function()
            apply_snacks_highlights()
        end)

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_snacks_highlights,
        })
    end,
}
