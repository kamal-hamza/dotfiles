return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>ha", function() require("harpoon"):list():add() end,                                    desc = "Harpoon: Add File" },
        { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: Toggle Menu" },
        { "1",          function() require("harpoon"):list():select(1) end,                                desc = "Harpoon: Go to File 1" },
        { "2",          function() require("harpoon"):list():select(2) end,                                desc = "Harpoon: Go to File 2" },
        { "3",          function() require("harpoon"):list():select(3) end,                                desc = "Harpoon: Go to File 3" },
        { "4",          function() require("harpoon"):list():select(4) end,                                desc = "Harpoon: Go to File 4" },
        { "<leader>hn", function() require("harpoon"):list():next() end,                                   desc = "Harpoon: Next File" },
        { "<leader>hp", function() require("harpoon"):list():prev() end,                                   desc = "Harpoon: Previous File" },
    },
    config = function()
        local harpoon = require("harpoon")

        -- REQUIRED
        harpoon:setup({
            settings = {
                save_on_toggle = true,
                sync_on_ui_close = true,
                key = function()
                    return vim.loop.cwd()
                end,
            },
        })

        -- Set up custom highlights to match theme
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
                        bg_elevated = "#1a1a1a",
                        fg = "#f5f5f5",
                        border = "#333333",
                        blue_light = "#67b7f5",
                    }
                end

                vim.api.nvim_set_hl(0, "HarpoonWindow", { bg = colors.bg, fg = colors.fg })
                vim.api.nvim_set_hl(0, "HarpoonBorder", { bg = colors.bg, fg = colors.border })
                vim.api.nvim_set_hl(0, "HarpoonTitle", { bg = colors.bg, fg = colors.blue_light, bold = true })
            end,
        })

        -- Trigger the autocmd for the current colorscheme
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
