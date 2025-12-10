return {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
        { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" },
    },
    opts = {
        -- Where to open the outline window
        outline_window = {
            position = "right",
            width = 25,
            relative_width = true,
            auto_close = false,
            auto_jump = false,
            jump_highlight_duration = 300,
            center_on_jump = true,
            show_numbers = false,
            show_relative_numbers = false,
            wrap = false,
            show_cursorline = true,
            hide_cursor = false,
            focus_on_open = true,
            winhl = "",
        },
        -- Outline items configuration
        outline_items = {
            show_symbol_details = true,
            show_symbol_lineno = false,
            highlight_hovered_item = true,
            auto_set_cursor = true,
            auto_unfold_hover = true,
            auto_update_events = {
                follow = { "CursorMoved" },
                items = { "InsertLeave", "WinEnter", "BufEnter", "BufWinEnter", "TabEnter", "BufWritePost" },
            },
        },
        -- Guides configuration
        guides = {
            enabled = true,
            markers = {
                bottom = "└",
                middle = "├",
                vertical = "│",
            },
        },
        -- Symbol folding configuration
        symbol_folding = {
            autofold_depth = 1,
            auto_unfold = {
                hovered = true,
                only = true,
            },
            markers = { "", "" },
        },
        -- Preview window configuration
        preview_window = {
            auto_preview = false,
            open_hover_on_preview = false,
            width = 50,
            min_width = 50,
            relative_width = true,
            border = "rounded",
            winhl = "NormalFloat:",
            winblend = 0,
            live = false,
        },
        -- Keymaps for the outline window
        keymaps = {
            show_help = "?",
            close = { "<Esc>", "q" },
            goto_location = "<Cr>",
            peek_location = "o",
            goto_and_close = "<S-Cr>",
            restore_location = "<C-g>",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "r",
            code_actions = "a",
            fold = "h",
            unfold = "l",
            fold_toggle = "<Tab>",
            fold_toggle_all = "<S-Tab>",
            fold_all = "W",
            unfold_all = "E",
            fold_reset = "R",
            down_and_goto = "<C-j>",
            up_and_goto = "<C-k>",
        },
        -- Providers configuration (LSP and Treesitter)
        providers = {
            priority = { "lsp", "coc", "markdown", "norg" },
            lsp = {
                blacklist_clients = {},
            },
        },
        -- Symbol icons (using nerd fonts)
        symbols = {
            icons = {
                File = { icon = "󰈔", hl = "Identifier" },
                Module = { icon = "󰆧", hl = "Include" },
                Namespace = { icon = "󰅪", hl = "Include" },
                Package = { icon = "󰏗", hl = "Include" },
                Class = { icon = "𝓒", hl = "Type" },
                Method = { icon = "ƒ", hl = "Function" },
                Property = { icon = "", hl = "Identifier" },
                Field = { icon = "󰆨", hl = "Identifier" },
                Constructor = { icon = "", hl = "Special" },
                Enum = { icon = "ℰ", hl = "Type" },
                Interface = { icon = "󰜰", hl = "Type" },
                Function = { icon = "", hl = "Function" },
                Variable = { icon = "", hl = "Constant" },
                Constant = { icon = "", hl = "Constant" },
                String = { icon = "𝓐", hl = "String" },
                Number = { icon = "#", hl = "Number" },
                Boolean = { icon = "⊨", hl = "Boolean" },
                Array = { icon = "󰅪", hl = "Constant" },
                Object = { icon = "⦿", hl = "Type" },
                Key = { icon = "🔐", hl = "Type" },
                Null = { icon = "NULL", hl = "Type" },
                EnumMember = { icon = "", hl = "Identifier" },
                Struct = { icon = "𝓢", hl = "Structure" },
                Event = { icon = "🗲", hl = "Type" },
                Operator = { icon = "+", hl = "Identifier" },
                TypeParameter = { icon = "𝙏", hl = "Identifier" },
                Component = { icon = "󰅴", hl = "Function" },
                Fragment = { icon = "󰅴", hl = "Constant" },
                TypeAlias = { icon = " ", hl = "Type" },
                Parameter = { icon = " ", hl = "Identifier" },
                StaticMethod = { icon = " ", hl = "Function" },
                Macro = { icon = " ", hl = "Function" },
            },
        },
    },
    config = function(_, opts)
        require("outline").setup(opts)

        -- Custom highlights
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
                local colors
                local theme_name = vim.g.colors_name

                if theme_name and (theme_name:match("soft%-focus") or theme_name:match("soft_focus")) then
                    local theme_module = "plugins.themes." .. theme_name
                    local ok, theme = pcall(require, theme_module)
                    if ok and theme.colors then
                        colors = theme.colors
                    end
                end

                if not colors then
                    colors = {
                        bg = "#050505",
                        fg = "#f5f5f5",
                        fg_alt = "#bbbbbb",
                        blue = "#448cbb",
                        blue_light = "#67b7f5",
                        comment = "#888888",
                        cursor_line = "#1a1a1a",
                    }
                end

                -- Outline window highlights
                vim.api.nvim_set_hl(0, "OutlineGuides", { fg = colors.comment or "#888888" })
                vim.api.nvim_set_hl(0, "OutlineCurrent",
                    { bg = colors.cursor_line or "#1a1a1a", fg = colors.blue_light or "#67b7f5", bold = true })
                vim.api.nvim_set_hl(0, "OutlineFoldMarker", { fg = colors.blue or "#448cbb" })
                vim.api.nvim_set_hl(0, "OutlineDetails", { fg = colors.fg_alt or "#bbbbbb", italic = true })
            end,
        })

        -- Trigger initial highlight setup
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
