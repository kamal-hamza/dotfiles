return {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    config = function()
        local gitsigns = require("gitsigns")

        gitsigns.setup({
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
        })

        -- Apply Soft Focus theme colors to gitsigns
        local function apply_gitsigns_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}

            -- Git sign colors
            vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.git_add or colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.git_change or colors.orange or "#D4B87B" })
            vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.git_delete or colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = colors.git_delete or colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = colors.git_change or colors.orange or "#D4B87B" })
            vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = colors.comment or "#888888" })

            -- Staged signs
            vim.api.nvim_set_hl(0, "GitSignsStagedAdd", { fg = colors.git_add or colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "GitSignsStagedChange", { fg = colors.git_change or colors.orange or "#D4B87B" })
            vim.api.nvim_set_hl(0, "GitSignsStagedDelete", { fg = colors.git_delete or colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "GitSignsStagedTopdelete", { fg = colors.git_delete or colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "GitSignsStagedChangedelete",
                { fg = colors.git_change or colors.orange or "#D4B87B" })

            -- Line highlights
            vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#0f1f0f" })
            vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#1f1f0f" })
            vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#1f0f0f" })

            -- Preview highlights
            vim.api.nvim_set_hl(0, "GitSignsAddPreview", { fg = colors.git_add or colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "GitSignsDeletePreview", { fg = colors.git_delete or colors.red or "#C42847" })

            -- Inline highlights
            vim.api.nvim_set_hl(0, "GitSignsAddInline",
                { bg = "#1a3a1a", fg = colors.green or "#77aa77", bold = true })
            vim.api.nvim_set_hl(0, "GitSignsDeleteInline",
                { bg = "#3a1a1a", fg = colors.red or "#C42847", bold = true })
            vim.api.nvim_set_hl(0, "GitSignsChangeInline",
                { bg = "#3a3a1a", fg = colors.orange or "#D4B87B", bold = true })
        end

        -- Apply highlights on startup
        apply_gitsigns_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_gitsigns_highlights,
        })
    end,
}
