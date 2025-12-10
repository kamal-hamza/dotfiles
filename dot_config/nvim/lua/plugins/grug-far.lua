return {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
        {
            "<leader>sr",
            function()
                require("grug-far").open()
            end,
            desc = "Search and Replace (Grug Far)",
        },
        {
            "<leader>sw",
            function()
                require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
            end,
            desc = "Search and Replace Word (Grug Far)",
        },
        {
            "<leader>sf",
            function()
                require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
            end,
            desc = "Search and Replace in File (Grug Far)",
        },
    },
    config = function()
        require("grug-far").setup({
            -- Engine to use (ripgrep or astgrep)
            engine = "ripgrep",
            -- Grug window configuration
            windowCreationCommand = "vsplit",
            -- Minimum number of chars to start searching
            minSearchChars = 2,
            -- Max number of parallel replacements tasks
            maxWorkers = 4,
            -- Debounce ms for search typing
            searchOnInsertLeave = false,
            -- Extra args for search
            extraRgArgs = "",
            -- Keymaps for normal mode
            keymaps = {
                replace = { n = "<localleader>r" },
                qflist = { n = "<localleader>q" },
                syncLocations = { n = "<localleader>s" },
                syncLine = { n = "<localleader>l" },
                close = { n = "<localleader>c" },
                historyOpen = { n = "<localleader>t" },
                historyAdd = { n = "<localleader>a" },
                refresh = { n = "<localleader>f" },
                openLocation = { n = "<localleader>o" },
                gotoLocation = { n = "<enter>" },
                pickHistoryEntry = { n = "<enter>" },
                abort = { n = "<localleader>b" },
                help = { n = "g?" },
                toggleShowCommand = { n = "<localleader>p" },
            },
            -- Icons
            icons = {
                enabled = true,
                actionEntryBullet = "  ",
            },
            -- Spinner
            spinnerStates = {
                "⠋",
                "⠙",
                "⠹",
                "⠸",
                "⠼",
                "⠴",
                "⠦",
                "⠧",
                "⠇",
                "⠏",
            },
        })
    end,
}
