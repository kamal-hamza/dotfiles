return {
    'echasnovski/mini.nvim',
    version = "*",
    dependencies = {
        { 'echasnovski/mini.pairs', version = '*' },
        { 'echasnovski/mini.icons', version = '*' },
        { 'echasnovski/mini.pick',  version = '*' },
    },
    keys = {
        { "<leader>ff", function() require('mini.pick').builtin.files() end,     desc = "Find Files (Mini Pick)" },
        { "<leader>fb", function() require('mini.pick').builtin.buffers() end,   desc = "Buffers (Mini Pick)" },
        { "<leader>fg", function() require('mini.pick').builtin.grep_live() end, desc = "Live Grep (Mini Pick)" },
        { "<leader>fh", function() require('mini.pick').builtin.help() end,      desc = "Help Tags (Mini Pick)" },
    },
    config = function()
        -- Setup mini.pairs
        require("mini.pairs").setup()

        -- Setup mini.icons
        require("mini.icons").setup()

        -- Setup mini.pick with configuration
        local pick = require("mini.pick")
        pick.setup({
            -- Delay (in ms) between forcing asynchronous behavior
            delay = {
                async = 10,
                busy = 50,
            },

            -- Keys for mapping
            mappings = {
                caret_left = '<Left>',
                caret_right = '<Right>',

                choose = '<CR>',
                choose_in_split = '<C-s>',
                choose_in_tabpage = '<C-t>',
                choose_in_vsplit = '<C-v>',
                choose_marked = '<M-CR>',

                delete_char = '<BS>',
                delete_char_right = '<Del>',
                delete_left = '<C-u>',
                delete_word = '<C-w>',

                mark = '<C-x>',
                mark_all = '<C-a>',

                move_down = '<C-n>',
                move_start = '<C-g>',
                move_up = '<C-p>',

                paste = '<C-r>',

                refine = '<C-Space>',
                refine_marked = '<M-Space>',

                scroll_down = '<C-f>',
                scroll_left = '<C-h>',
                scroll_right = '<C-l>',
                scroll_up = '<C-b>',

                stop = '<Esc>',

                toggle_info = '<S-Tab>',
                toggle_preview = '<Tab>',
            },

            -- General options
            options = {
                -- Whether to show content from bottom to top
                content_from_bottom = false,

                -- Whether to cache matches (more speed and memory usage)
                use_cache = true,
            },

            -- Window related options
            window = {
                -- Float window config
                config = function()
                    local height = math.floor(0.618 * vim.o.lines)
                    local width = math.floor(0.618 * vim.o.columns)
                    return {
                        anchor = 'NW',
                        border = 'rounded',
                        col = math.floor(0.5 * (vim.o.columns - width)),
                        height = height,
                        row = math.floor(0.5 * (vim.o.lines - height)),
                        width = width,
                    }
                end,

                -- String to use for prompt
                prompt_caret = '▏',
                prompt_prefix = '   ',
            },
        })

        -- Set up highlight groups to match theme
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
                local colors
                local theme_name = vim.g.colors_name

                -- Try to load the theme module dynamically
                if theme_name and (theme_name:match("soft%-focus") or theme_name:match("soft_focus")) then
                    local theme_module = "plugins.themes." .. theme_name
                    local ok, theme = pcall(require, theme_module)
                    if ok and theme.colors then
                        colors = theme.colors
                    end
                end

                -- Fallback colors if theme not found
                if not colors then
                    colors = {
                        bg = "#050505",
                        bg_alt = "#0a0a0a",
                        bg_elevated = "#1a1a1a",
                        fg = "#f5f5f5",
                        fg_alt = "#bbbbbb",
                        border = "#333333",
                        blue = "#448cbb",
                        blue_light = "#67b7f5",
                        green = "#77aa77",
                    }
                end

                -- Mini.pick highlights
                vim.api.nvim_set_hl(0, "MiniPickNormal", { bg = colors.bg, fg = colors.fg })
                vim.api.nvim_set_hl(0, "MiniPickBorder", { bg = colors.bg, fg = colors.border })
                vim.api.nvim_set_hl(0, "MiniPickBorderText", { bg = colors.bg, fg = colors.blue, bold = true })
                vim.api.nvim_set_hl(0, "MiniPickPrompt", { bg = colors.bg, fg = colors.blue_light, bold = true })
                vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { bg = colors.bg_elevated, fg = colors.fg, bold = true })
                vim.api.nvim_set_hl(0, "MiniPickMatchMarked", { bg = colors.bg_alt, fg = colors.green })
                vim.api.nvim_set_hl(0, "MiniPickMatchRanges", { fg = colors.blue_light, bold = true })
                vim.api.nvim_set_hl(0, "MiniPickPreview", { bg = colors.bg })
            end,
        })

        -- Trigger the autocmd for the current colorscheme
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end
}
