-- dressing.nvim - Improved vim.ui interfaces
-- Provides better UI for vim.ui.select() and vim.ui.input()

return {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.select = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.select(...)
        end
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.input = function(...)
            require("lazy").load({ plugins = { "dressing.nvim" } })
            return vim.ui.input(...)
        end
    end,
    opts = {
        input = {
            -- Set to false to disable the vim.ui.input implementation
            enabled = true,

            -- Default prompt string
            default_prompt = "Input:",

            -- Can be 'left', 'right', or 'center'
            title_pos = "left",

            -- When true, <Esc> will close the modal
            insert_only = true,

            -- When true, input will start in insert mode.
            start_in_insert = true,

            -- These are passed to nvim_open_win
            border = "rounded",
            -- 'editor' and 'win' will default to being centered
            relative = "cursor",

            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            prefer_width = 40,
            width = nil,
            -- min_width and max_width can be a list of mixed types.
            -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
            max_width = { 140, 0.9 },
            min_width = { 20, 0.2 },

            buf_options = {},
            win_options = {
                -- Disable line wrapping
                wrap = false,
                -- Indicator for when text exceeds window
                list = true,
                listchars = "precedes:…,extends:…",
                -- Increase this for more context
                sidescrolloff = 0,
            },

            -- Set to `false` to disable
            mappings = {
                n = {
                    ["<Esc>"] = "Close",
                    ["<CR>"] = "Confirm",
                },
                i = {
                    ["<C-c>"] = "Close",
                    ["<CR>"] = "Confirm",
                    ["<Up>"] = "HistoryPrev",
                    ["<Down>"] = "HistoryNext",
                },
            },

            override = function(conf)
                -- This is the config that will be passed to nvim_open_win.
                -- Change values here to customize the layout
                return conf
            end,

            -- see :help dressing_get_config
            get_config = nil,
        },
        select = {
            -- Set to false to disable the vim.ui.select implementation
            enabled = true,

            -- Priority list of preferred vim.select implementations
            backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },

            -- Trim trailing `:` from prompt
            trim_prompt = true,

            -- Options for telescope selector
            -- These are passed into the telescope picker directly. Can be used like:
            -- dressing.select(..., { telescope = { layout_config = {...} } })
            telescope = nil,

            -- Options for fzf selector
            fzf = {
                window = {
                    width = 0.5,
                    height = 0.4,
                },
            },

            -- Options for fzf-lua
            fzf_lua = {
                -- winopts = {
                --   height = 0.5,
                --   width = 0.5,
                -- },
            },

            -- Options for nui Menu
            nui = {
                position = "50%",
                size = nil,
                relative = "editor",
                border = {
                    style = "rounded",
                },
                buf_options = {
                    swapfile = false,
                    filetype = "DressingSelect",
                },
                win_options = {
                    winblend = 0,
                },
                max_width = 80,
                max_height = 40,
                min_width = 40,
                min_height = 10,
            },

            -- Options for built-in selector
            builtin = {
                -- Display numbers for options and set up keymaps
                show_numbers = true,
                -- These are passed to nvim_open_win
                border = "rounded",
                -- 'editor' and 'win' will default to being centered
                relative = "editor",

                buf_options = {},
                win_options = {
                    cursorline = true,
                    cursorlineopt = "both",
                },

                -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
                -- the min_ and max_ options can be a list of mixed types.
                -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
                width = nil,
                max_width = { 140, 0.8 },
                min_width = { 40, 0.2 },
                height = nil,
                max_height = 0.9,
                min_height = { 10, 0.2 },

                -- Set to `false` to disable
                mappings = {
                    ["<Esc>"] = "Close",
                    ["<C-c>"] = "Close",
                    ["<CR>"] = "Confirm",
                },

                override = function(conf)
                    -- This is the config that will be passed to nvim_open_win.
                    -- Change values here to customize the layout
                    return conf
                end,
            },

            -- Used to override format_item. See :help dressing-format
            format_item_override = {},

            -- see :help dressing_get_config
            get_config = nil,
        },
    },
    config = function(_, opts)
        require("dressing").setup(opts)

        -- Apply Soft Focus theme colors to dressing windows
        local function apply_dressing_highlights()
            local theme_name = vim.g.colors_name or "soft-focus-dark"
            local theme_module = "plugins.themes." .. theme_name
            local has_theme, theme = pcall(require, theme_module)

            if not has_theme then
                return
            end

            local colors = theme.colors or {}
            local bg = colors.bg or "#050505"
            local bg_alt = colors.bg_alt or "#0a0a0a"
            local bg_elevated = colors.bg_elevated or "#1a1a1a"
            local fg = colors.fg or "#f5f5f5"
            local blue = colors.blue or "#448cbb"
            local border = colors.border or "#333333"

            -- Input window
            vim.api.nvim_set_hl(0, "DressingInputNormalFloat", { bg = bg_alt, fg = fg })
            vim.api.nvim_set_hl(0, "DressingInputFloatBorder", { bg = bg_alt, fg = blue })
            vim.api.nvim_set_hl(0, "DressingInputFloatTitle", { bg = bg_alt, fg = blue, bold = true })

            -- Select window
            vim.api.nvim_set_hl(0, "DressingSelectNormalFloat", { bg = bg, fg = fg })
            vim.api.nvim_set_hl(0, "DressingSelectFloatBorder", { bg = bg, fg = border })
            vim.api.nvim_set_hl(0, "DressingSelectFloatTitle", { bg = bg, fg = blue, bold = true })
            vim.api.nvim_set_hl(0, "DressingSelectIdx", { fg = blue, bold = true })
        end

        -- Apply highlights on load
        apply_dressing_highlights()

        -- Reapply on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = apply_dressing_highlights,
        })
    end,
}
