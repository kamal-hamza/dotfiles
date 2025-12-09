-- Enhanced Lualine Configuration inspired by nikolovlazar's dotfiles
-- Adapted to use Soft Focus theme colors

return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        event = "VeryLazy",
        config = function()
            local lualine = require('lualine')

            -- Get theme colors based on background mode
            local function get_theme_colors()
                local theme_state_file = vim.fn.stdpath("config") .. "/.theme-mode"
                local theme = "dark"
                if vim.fn.filereadable(theme_state_file) == 1 then
                    local f = io.open(theme_state_file, "r")
                    if f then
                        theme = f:read("*line") or "dark"
                        f:close()
                    end
                end

                if theme == "light" then
                    return {
                        bg = "#ffffff",
                        fg = "#000000",
                        fg_alt = "#666666",
                        yellow = "#b8943d",
                        cyan = "#4da6ff",
                        green = "#558855",
                        orange = "#b8943d",
                        violet = "#9a6e6d",
                        magenta = "#9a6e6d",
                        blue = "#448cbb",
                        red = "#C42847",
                        pink = "#9a6e6d",
                    }
                else
                    return {
                        bg = "#050505",
                        fg = "#f5f5f5",
                        fg_alt = "#bbbbbb",
                        yellow = "#D4B87B",
                        cyan = "#67b7f5",
                        green = "#77aa77",
                        orange = "#D4B87B",
                        violet = "#B88E8D",
                        magenta = "#B88E8D",
                        blue = "#448cbb",
                        red = "#C42847",
                        pink = "#B88E8D",
                    }
                end
            end

            -- Apply custom highlights
            local function apply_highlights()
                local c = get_theme_colors()

                vim.api.nvim_set_hl(0, 'LualineNormalC', { fg = c.fg, bg = c.bg })
                vim.api.nvim_set_hl(0, 'LualineInactiveC', { fg = c.fg, bg = c.bg })
                vim.api.nvim_set_hl(0, 'LualineFilename', { fg = c.fg, bg = c.bg })

                vim.api.nvim_set_hl(0, 'LualineDiagnosticsError', { bg = c.bg, fg = c.red })
                vim.api.nvim_set_hl(0, 'LualineDiagnosticsWarn', { bg = c.bg, fg = c.yellow })
                vim.api.nvim_set_hl(0, 'LualineDiagnosticsInfo', { bg = c.bg, fg = c.cyan })
                vim.api.nvim_set_hl(0, 'LualineBranch', { bg = c.bg, fg = c.violet, bold = true })
                vim.api.nvim_set_hl(0, 'LualineDiffAdded', { bg = c.bg, fg = c.green, bold = true })
                vim.api.nvim_set_hl(0, 'LualineDiffModified', { bg = c.bg, fg = c.orange, bold = true })
                vim.api.nvim_set_hl(0, 'LualineDiffRemoved', { bg = c.bg, fg = c.red, bold = true })
            end

            apply_highlights()

            -- Conditions helper
            local conditions = {
                buffer_not_empty = function()
                    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
                end,
                hide_in_width = function()
                    return vim.fn.winwidth(0) > 80
                end,
                check_git_workspace = function()
                    local filepath = vim.fn.expand('%:p:h')
                    local gitdir = vim.fn.finddir('.git', filepath .. ';')
                    return gitdir and #gitdir > 0 and #gitdir < #filepath
                end,
            }

            -- Config
            local config = {
                options = {
                    component_separators = '',
                    section_separators = '',
                    theme = {
                        normal = { c = 'LualineNormalC' },
                        inactive = { c = 'LualineInactiveC' },
                    },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {},
                    lualine_x = {},
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_y = {},
                    lualine_z = {},
                    lualine_c = {},
                    lualine_x = {},
                },
            }

            local function ins_left(component)
                table.insert(config.sections.lualine_c, component)
            end

            local function ins_right(component)
                table.insert(config.sections.lualine_x, component)
            end

            -- Mode indicator
            ins_left({
                function()
                    return ''
                end,
                color = function()
                    local c = get_theme_colors()
                    local mode_color = {
                        n = c.blue,   -- Normal: blue
                        i = c.green,  -- Insert: green
                        v = c.violet, -- Visual: violet
                        [''] = c.violet,
                        V = c.violet,
                        c = c.orange, -- Command: orange
                        no = c.blue,
                        s = c.pink,   -- Select: pink
                        S = c.pink,
                        [''] = c.pink,
                        ic = c.green,
                        R = c.red, -- Replace: red
                        Rv = c.red,
                        cv = c.orange,
                        ce = c.orange,
                        r = c.cyan,
                        rm = c.cyan,
                        ['r?'] = c.cyan,
                        ['!'] = c.red,
                        t = c.cyan, -- Terminal: cyan
                    }
                    return { bg = c.bg, fg = mode_color[vim.fn.mode()] }
                end,
                padding = { right = 1 },
            })

            -- Filename
            ins_left({
                'filename',
                cond = conditions.buffer_not_empty,
                color = 'LualineFilename',
                path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
                shorting_target = 40,
                symbols = {
                    modified = ' 󰧞',
                    readonly = ' ',
                    unnamed = '[No Name]',
                }
            })

            -- Diagnostics
            ins_left({
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                diagnostics_color = {
                    error = 'LualineDiagnosticsError',
                    warn = 'LualineDiagnosticsWarn',
                    info = 'LualineDiagnosticsInfo',
                },
            })

            -- Mid section spacer
            ins_left({
                function()
                    return '%='
                end,
            })

            -- Git branch
            ins_right({
                'branch',
                icon = '',
                color = 'LualineBranch',
            })

            -- Git diff
            ins_right({
                'diff',
                symbols = { added = ' ', modified = ' ', removed = ' ' },
                diff_color = {
                    added = 'LualineDiffAdded',
                    modified = 'LualineDiffModified',
                    removed = 'LualineDiffRemoved',
                },
                cond = conditions.hide_in_width,
            })

            -- File progress
            ins_right({
                'progress',
                color = function()
                    local c = get_theme_colors()
                    return { fg = c.fg, bg = c.bg }
                end,
            })

            -- Location
            ins_right({
                'location',
                color = function()
                    local c = get_theme_colors()
                    return { fg = c.blue, bg = c.bg, bold = true }
                end,
            })

            lualine.setup(config)

            -- Reapply highlights on colorscheme change
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    apply_highlights()
                end,
            })
        end,
    },
}
