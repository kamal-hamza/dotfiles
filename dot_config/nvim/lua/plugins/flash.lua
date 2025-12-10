return {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash",
        },
        {
            "S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash Treesitter",
        },
        {
            "r",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Remote Flash",
        },
        {
            "R",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "Treesitter Search",
        },
        {
            "<c-s>",
            mode = { "c" },
            function()
                require("flash").toggle()
            end,
            desc = "Toggle Flash Search",
        },
    },
    opts = {
        -- Labels to use for jump targets
        labels = "asdfghjklqwertyuiopzxcvbnm",
        -- Search options
        search = {
            -- Search mode: exact, search, fuzzy
            mode = "exact",
            -- Behave like `incsearch`
            incremental = false,
            -- When `false`, find only matches in the given direction
            forward = true,
            -- Wrap around when reaching the end
            wrap = true,
            -- Multi-window search
            multi_window = true,
            -- Exclude certain windows from search
            exclude = {
                "notify",
                "noice",
                "cmp_menu",
            },
        },
        -- Jump options
        jump = {
            -- Jump position
            jumplist = true,
            -- Jump to first match
            pos = "start",
            -- Automatically jump when there is only one match
            autojump = false,
            -- Clear highlight after jump
            nohlsearch = false,
        },
        -- Label options
        label = {
            -- Allow uppercase labels
            uppercase = true,
            -- Add a label for the first match in the current window
            current = true,
            -- Show the label after the match
            after = true,
            -- Show the label before the match
            before = false,
            -- Position of the label extmark
            style = "overlay",
            -- Minimum pattern length
            min_pattern_length = 0,
            -- Enable rainbow colors for labels
            rainbow = {
                enabled = false,
                shade = 5,
            },
        },
        -- Highlight options
        highlight = {
            -- Show a backdrop with hl FlashBackdrop
            backdrop = true,
            -- Highlight the search matches
            matches = true,
            -- Extmark priority
            priority = 5000,
            groups = {
                match = "FlashMatch",
                current = "FlashCurrent",
                backdrop = "FlashBackdrop",
                label = "FlashLabel",
            },
        },
        -- Action to perform when picking a label
        action = nil,
        -- Character to use as a pattern for search
        pattern = "",
        -- Continue last search
        continue = false,
        -- Flash modes
        modes = {
            -- Flash on search
            search = {
                enabled = true,
                highlight = { backdrop = false },
                jump = { history = true, register = true, nohlsearch = true },
                search = {
                    mode = "search",
                    incremental = true,
                },
            },
            -- Flash on character search (f, F, t, T)
            char = {
                enabled = true,
                -- Hide after jump when not using jump labels
                autohide = false,
                -- Show jump labels
                jump_labels = false,
                -- Set to `false` to use the current line only
                multi_line = true,
                -- When using jump labels, don't use these keys
                label = { exclude = "hjkliardc" },
                keys = { "f", "F", "t", "T", ";", "," },
                char_actions = function(motion)
                    return {
                        [";"] = "next",
                        [","] = "prev",
                        [motion:lower()] = "next",
                        [motion:upper()] = "prev",
                    }
                end,
                search = { wrap = false },
                highlight = { backdrop = true },
                jump = { register = false },
            },
            -- Flash on treesitter selections
            treesitter = {
                labels = "abcdefghijklmnopqrstuvwxyz",
                jump = { pos = "range" },
                search = { incremental = false },
                label = { before = true, after = true, style = "inline" },
                highlight = {
                    backdrop = false,
                    matches = false,
                },
            },
            -- Flash on treesitter search
            treesitter_search = {
                jump = { pos = "range" },
                search = { multi_window = true, wrap = true, incremental = false },
                remote_op = { restore = true },
                label = { before = true, after = true, style = "inline" },
            },
            -- Flash on remote operations
            remote = {
                remote_op = { restore = true, motion = true },
            },
        },
        -- Prompt configuration
        prompt = {
            enabled = true,
            prefix = { { "⚡", "FlashPromptIcon" } },
            win_config = {
                relative = "editor",
                width = 1,
                height = 1,
                row = -1,
                col = 0,
                zindex = 1000,
            },
        },
    },
    config = function(_, opts)
        require("flash").setup(opts)

        -- Custom highlights for flash
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
                        bg_alt = "#0a0a0a",
                        blue_light = "#67b7f5",
                        orange = "#D4B87B",
                        red = "#C42847",
                        comment = "#888888",
                    }
                end

                -- Flash highlights
                vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = colors.comment or "#888888" })
                vim.api.nvim_set_hl(0, "FlashMatch",
                    { bg = colors.bg_alt or "#0a0a0a", fg = colors.blue_light or "#67b7f5", bold = true })
                vim.api.nvim_set_hl(0, "FlashCurrent",
                    { bg = colors.bg_alt or "#0a0a0a", fg = colors.orange or "#D4B87B", bold = true })
                vim.api.nvim_set_hl(0, "FlashLabel", { bg = colors.red or "#C42847", fg = "#ffffff", bold = true })
                vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = colors.blue_light or "#67b7f5" })
                vim.api.nvim_set_hl(0, "FlashPrompt",
                    { bg = colors.bg or "#050505", fg = colors.blue_light or "#67b7f5" })
            end,
        })

        -- Trigger initial highlight setup
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
