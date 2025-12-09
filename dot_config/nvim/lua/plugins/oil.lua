return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        default_file_explorer = true,
        columns = {
            "icon",
        },
        view_options = {
            show_hidden = true,
            is_always_hidden = function(name, _)
                return name == ".." or name == ".git"
            end,
        },
        float = {
            padding = 2,
            max_width = 90,
            max_height = 30,
            border = "rounded",
            win_options = {
                winblend = 0,
            },
        },
        keymaps = {
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.select",
            ["<C-v>"] = "actions.select_vsplit",
            ["<C-x>"] = "actions.select_split",
            ["<C-t>"] = "actions.select_tab",
            ["<C-p>"] = "actions.preview",
            ["<C-c>"] = "actions.close",
            ["<C-r>"] = "actions.refresh",
            ["-"] = "actions.parent",
            ["_"] = "actions.open_cwd",
            ["`"] = "actions.cd",
            ["~"] = "actions.tcd",
            ["gs"] = "actions.change_sort",
            ["gx"] = "actions.open_external",
            ["g."] = "actions.toggle_hidden",
            ["g\\"] = "actions.toggle_trash",
        },
    },
    config = function(_, opts)
        require("oil").setup(opts)

        -- Apply Soft Focus theme colors to oil
        local function apply_oil_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}
            local bg = colors.bg or "#050505"
            local fg = colors.fg or "#f5f5f5"
            local border = colors.border or "#333333"
            local blue = colors.blue or "#448cbb"
            local cyan = colors.cyan or colors.blue_light or "#67b7f5"
            local comment = colors.comment or "#888888"

            -- Oil window
            vim.api.nvim_set_hl(0, "OilDir", { fg = cyan, bold = true })
            vim.api.nvim_set_hl(0, "OilDirIcon", { fg = cyan })
            vim.api.nvim_set_hl(0, "OilLink", { fg = blue })
            vim.api.nvim_set_hl(0, "OilLinkTarget", { fg = comment })
            vim.api.nvim_set_hl(0, "OilCopy", { fg = colors.green or "#77aa77", bold = true })
            vim.api.nvim_set_hl(0, "OilMove", { fg = colors.orange or "#d4956b", bold = true })
            vim.api.nvim_set_hl(0, "OilChange", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "OilCreate", { fg = colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "OilDelete", { fg = colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "OilPermissionNone", { fg = comment })
            vim.api.nvim_set_hl(0, "OilPermissionRead", { fg = colors.green or "#77aa77" })
            vim.api.nvim_set_hl(0, "OilPermissionWrite", { fg = colors.orange or "#d4956b" })
            vim.api.nvim_set_hl(0, "OilPermissionExecute", { fg = colors.red or "#C42847" })
            vim.api.nvim_set_hl(0, "OilSocket", { fg = colors.purple or "#B88E8D" })
            vim.api.nvim_set_hl(0, "OilSize", { fg = comment })
        end

        -- Apply highlights on startup
        apply_oil_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_oil_highlights,
        })
    end,
}
