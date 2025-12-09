return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    cmd = "Telescope",
    keys = {
        { "<leader>fB",      "<cmd>Telescope buffers<cr>",                                                               desc = "Buffers (Telescope)" },
        { "<leader>fc",      function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>fF",      "<cmd>Telescope find_files<cr>",                                                            desc = "Find Files (Telescope with Preview)" },
        { "<leader>fG",      "<cmd>Telescope git_files<cr>",                                                             desc = "Find Git Files (Telescope)" },
        { "<leader>fr",      "<cmd>Telescope oldfiles<cr>",                                                              desc = "Recent Files" },
        { "<leader><space>", "<cmd>Telescope find_files<cr>",                                                            desc = "Find Files (Telescope)" },
        { "<leader>,",       "<cmd>Telescope buffers<cr>",                                                               desc = "Buffers" },
        { "<leader>/",       "<cmd>Telescope live_grep<cr>",                                                             desc = "Live Grep (Telescope)" },
        { "<leader>:",       "<cmd>Telescope command_history<cr>",                                                       desc = "Command History" },
        { "<leader>fH",      "<cmd>Telescope help_tags<cr>",                                                             desc = "Help Tags (Telescope)" },
        { "<leader>fk",      "<cmd>Telescope keymaps<cr>",                                                               desc = "Keymaps" },
        { "<leader>fm",      "<cmd>Telescope marks<cr>",                                                                 desc = "Marks" },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "",
                multi_icon = "  ",
                sorting_strategy = "ascending",
                layout_strategy = "horizontal",
                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.87,
                    height = 0.80,
                    preview_cutoff = 120,
                },
                borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                color_devicons = true,
                path_display = { "truncate" },
                dynamic_preview_title = true,
                mappings = {
                    i = {
                        -- Tab/Shift-Tab ONLY move selection (no multi-select)
                        ["<Tab>"] = actions.move_selection_next,
                        ["<S-Tab>"] = actions.move_selection_previous,

                        -- Ctrl+n/p for next/previous (vim-style)
                        ["<C-n>"] = actions.move_selection_next,
                        ["<C-p>"] = actions.move_selection_previous,

                        -- Ctrl+j/k for next/previous
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,

                        -- Use Space for multi-select toggle
                        ["<C-Space>"] = actions.toggle_selection + actions.move_selection_next,

                        -- Send selected to quickfix
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,

                        -- Close telescope
                        ["<C-c>"] = actions.close,
                        ["<Esc>"] = actions.close,

                        -- Scroll preview
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,

                        -- Cycle through history
                        ["<Down>"] = actions.cycle_history_next,
                        ["<Up>"] = actions.cycle_history_prev,
                    },
                    n = {
                        -- Tab/Shift-Tab ONLY move selection (no multi-select)
                        ["<Tab>"] = actions.move_selection_next,
                        ["<S-Tab>"] = actions.move_selection_previous,

                        -- j/k for movement
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["H"] = actions.move_to_top,
                        ["M"] = actions.move_to_middle,
                        ["L"] = actions.move_to_bottom,

                        -- gg/G for top/bottom
                        ["gg"] = actions.move_to_top,
                        ["G"] = actions.move_to_bottom,

                        -- Use Space for multi-select toggle
                        ["<Space>"] = actions.toggle_selection + actions.move_selection_next,

                        -- Send to quickfix
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,

                        -- Close
                        ["<Esc>"] = actions.close,
                        ["q"] = actions.close,

                        -- Scroll preview
                        ["<C-u>"] = actions.preview_scrolling_up,
                        ["<C-d>"] = actions.preview_scrolling_down,
                    },
                },
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                    "dist/",
                    "build/",
                    "target/",
                    "*.lock",
                },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
                buffers = {
                    show_all_buffers = true,
                    sort_lastused = true,
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.delete_buffer,
                        },
                        n = {
                            ["dd"] = actions.delete_buffer,
                        },
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
            },
        })

        -- Load extensions
        pcall(telescope.load_extension, "fzf")

        -- Set up custom highlights to match soft-focus theme
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = function()
                -- Get colors from the loaded theme
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

                -- Fallback to default colors if theme not found
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
                        red_bright = "#ff4c6a",
                        comment = "#888888",
                    }
                end

                -- Telescope main colors
                vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = colors.bg, fg = colors.fg })
                vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = colors.bg, fg = colors.border })
                vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = colors.bg_alt })
                vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = colors.bg_alt, fg = colors.border })
                vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = colors.blue, fg = colors.bg, bold = true })
                vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = colors.bg_alt, fg = colors.blue_light })

                vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = colors.green, fg = colors.bg, bold = true })
                vim.api.nvim_set_hl(0, "TelescopeResultsTitle",
                    { bg = colors.bg_elevated, fg = colors.fg_alt, bold = true })

                vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = colors.bg_elevated, fg = colors.fg, bold = true })
                vim.api.nvim_set_hl(0, "TelescopeSelectionCaret",
                    { bg = colors.bg_elevated, fg = colors.blue_light, bold = true })

                vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.blue_light, bold = true })
                vim.api.nvim_set_hl(0, "TelescopeMultiSelection", { bg = colors.bg_alt, fg = colors.red_bright })
            end,
        })

        -- Trigger the autocmd for the current colorscheme
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
