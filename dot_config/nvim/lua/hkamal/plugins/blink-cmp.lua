vim.pack.add({
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
    "https://github.com/Kaiser-Yang/blink-cmp-git",
    "https://github.com/onsails/lspkind.nvim",
    "https://github.com/xzbdmw/colorful-menu.nvim",
})

require("blink.cmp").setup({
    keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
    },
    appearance = {
        nerd_font_variant = "mono",
        kind_icons = require("lspkind").symbol_map,
    },
    completion = {
        documentation = { auto_show = false },
        menu = {
            auto_show = false,
            draw = {
                -- label_description is folded into label by colorful-menu.nvim
                columns = { { "kind_icon" }, { "label", gap = 1 } },
                components = {
                    label = {
                        text = function(ctx)
                            return require("colorful-menu").blink_components_text(ctx)
                        end,
                        highlight = function(ctx)
                            return require("colorful-menu").blink_components_highlight(ctx)
                        end,
                    },
                },
            },
        },
        list = {
            selection = {
                preselect = true,
                auto_insert = false,
            },
        },
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer", "git" },
        providers = {
            git = {
                module = "blink-cmp-git",
                name = "Git",
                enabled = function()
                    return vim.tbl_contains({ "gitcommit", "markdown" }, vim.bo.filetype)
                end,
                opts = {},
            },
        },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
})

vim.keymap.set("i", "<C-x><C-o>", function()
    require("blink.cmp").show()
end, { desc = "Trigger Completion" })

-- bold the characters that matched your query, like VSCode's IntelliSense
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { bold = true })
-- fade + strike deprecated items instead of just tinting them
vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#5c5c5c", strikethrough = true })
