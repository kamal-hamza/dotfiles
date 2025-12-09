-- Simple Winbar - Shows just the filename in top right corner
-- Breadcrumbs will be in the lualine statusbar instead

return {
    {
        "SmiteshP/nvim-navic",
        lazy = true,
        opts = {
            lsp = {
                auto_attach = true,
                preference = { "pyrefly" },  -- Prefer pyrefly over pyright
            },
            highlight = true,
            separator = "  ",
            depth_limit = 0,
            depth_limit_indicator = "..",
            safe_output = true,
            lazy_update_context = false,
            click = false,
        },
        config = function(_, opts)
            require("nvim-navic").setup(opts)

            -- Simple winbar that shows just the filename
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
                callback = function()
                    local filetype = vim.bo.filetype
                    local buftype = vim.bo.buftype

                    -- Exclude certain filetypes
                    local excluded_filetypes = {
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
                    }

                    -- Exclude certain buftypes
                    local excluded_buftypes = {
                        "terminal",
                        "nofile",
                        "quickfix",
                        "prompt",
                    }

                    if vim.tbl_contains(excluded_filetypes, filetype) or vim.tbl_contains(excluded_buftypes, buftype) then
                        vim.wo.winbar = nil
                        return
                    end

                    -- Get filename
                    local filename = vim.fn.expand("%:t")
                    if filename == "" then
                        filename = "[No Name]"
                    end

                    -- Check if modified
                    local modified = vim.bo.modified and " ●" or ""

                    -- Simple winbar with just filename
                    vim.wo.winbar = "%#WinBarFilename#  " .. filename .. "%#WinBarModified#" .. modified .. " "
                end,
            })

            -- Apply Soft Focus theme colors to winbar
            local function apply_winbar_highlights()
                local theme_name = vim.g.colors_name or "soft-focus-dark"
                local theme_module = "plugins.themes." .. theme_name
                local has_theme, theme = pcall(require, theme_module)

                if not has_theme then
                    return
                end

                local colors = theme.colors or {}

                local bg = colors.bg or "#050505"
                local blue = colors.blue or "#448cbb"
                local orange = colors.orange or "#d4956b"

                vim.api.nvim_set_hl(0, "WinBarFilename", { fg = blue, bg = bg, bold = true })
                vim.api.nvim_set_hl(0, "WinBarModified", { fg = orange, bg = bg })
            end

            -- Apply highlights on startup
            apply_winbar_highlights()

            -- Reapply on colorscheme change
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = apply_winbar_highlights,
            })
        end,
    },
}
