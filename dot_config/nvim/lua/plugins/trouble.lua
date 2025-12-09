return {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
        {
            "<leader>td",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer Diagnostics (Trouble)",
        },
        {
            "<leader>cs",
            "<cmd>Trouble symbols toggle focus=false<cr>",
            desc = "Symbols (Trouble)",
        },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
            desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
            "<leader>xL",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Location List (Trouble)",
        },
        {
            "<leader>xQ",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Quickfix List (Trouble)",
        },
    },
    config = function(_, opts)
        require("trouble").setup(opts)

        -- Apply Soft Focus theme colors to trouble
        local function apply_trouble_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}
            local bg = colors.bg or "#050505"
            local fg = colors.fg or "#f5f5f5"
            local fg_alt = colors.fg_alt or "#bbbbbb"
            local border = colors.border or "#333333"
            local cursor_line = colors.cursor_line or "#1a1a1a"
            local comment = colors.comment or "#888888"

            -- Trouble window
            vim.api.nvim_set_hl(0, "TroubleNormal", { bg = bg, fg = fg })
            vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = bg, fg = fg })
            vim.api.nvim_set_hl(0, "TroubleText", { fg = fg })
            vim.api.nvim_set_hl(0, "TroubleCount", { fg = colors.blue or "#448cbb", bold = true })
            vim.api.nvim_set_hl(0, "TroubleCode", { fg = comment })
            vim.api.nvim_set_hl(0, "TroubleDirectory", { fg = colors.cyan or "#67b7f5" })
            vim.api.nvim_set_hl(0, "TroubleSource", { fg = fg_alt })
            vim.api.nvim_set_hl(0, "TroubleIconArray", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconBoolean", { fg = colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "TroubleIconClass", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconConstant", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconConstructor", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconEnum", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconEnumMember", { fg = colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "TroubleIconEvent", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconField", { fg = colors.cyan or "#67b7f5" })
            vim.api.nvim_set_hl(0, "TroubleIconFile", { fg = fg })
            vim.api.nvim_set_hl(0, "TroubleIconFunction", { fg = colors.blue or "#448cbb" })
            vim.api.nvim_set_hl(0, "TroubleIconInterface", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconKey", { fg = colors.cyan or "#67b7f5" })
            vim.api.nvim_set_hl(0, "TroubleIconMethod", { fg = colors.blue or "#448cbb" })
            vim.api.nvim_set_hl(0, "TroubleIconModule", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconNamespace", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconNull", { fg = comment })
            vim.api.nvim_set_hl(0, "TroubleIconNumber", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconObject", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconOperator", { fg = fg })
            vim.api.nvim_set_hl(0, "TroubleIconPackage", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconProperty", { fg = colors.cyan or "#67b7f5" })
            vim.api.nvim_set_hl(0, "TroubleIconString", { fg = colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "TroubleIconStruct", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconTypeParameter", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "TroubleIconVariable", { fg = fg })

            -- Indent guides in trouble
            vim.api.nvim_set_hl(0, "TroubleIndent", { fg = border })
            vim.api.nvim_set_hl(0, "TroubleIndentFoldClosed", { fg = fg_alt })
            vim.api.nvim_set_hl(0, "TroubleIndentFoldOpen", { fg = fg_alt })
        end

        -- Apply highlights on startup
        apply_trouble_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_trouble_highlights,
        })
    end,
}
