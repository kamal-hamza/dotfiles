return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        -- Cmdline configuration
        cmdline = {
            enabled = true,
            view = "cmdline_popup",
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = true,         -- use a classic bottom cmdline for search
            command_palette = false,      -- disable to make cmdline show immediately
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
        routes = {
            {
                filter = {
                    event = "msg_show",
                    kind = "",
                    find = "written",
                },
                opts = { skip = true },
            },
            {
                filter = {
                    event = "msg_show",
                    find = "search hit BOTTOM",
                },
                opts = { skip = true },
            },
            {
                filter = {
                    event = "msg_show",
                    find = "search hit TOP",
                },
                opts = { skip = true },
            },
            {
                filter = {
                    event = "msg_show",
                    find = "lines yanked",
                },
                opts = { skip = true },
            },
        },
        views = {
            cmdline_popup = {
                position = {
                    row = 5,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            popupmenu = {
                relative = "editor",
                position = {
                    row = 8,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 10,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                },
            },
        },
    },
    keys = {
        {
            "<leader>sn",
            function()
                require("noice").cmd("history")
            end,
            desc = "Noice History",
        },
        {
            "<leader>sl",
            function()
                require("noice").cmd("last")
            end,
            desc = "Noice Last Message",
        },
        {
            "<leader>sd",
            function()
                require("noice").cmd("dismiss")
            end,
            desc = "Dismiss All Notifications",
        },
    },
}
