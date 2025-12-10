return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        "nvim-treesitter/nvim-treesitter",
    },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,               desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end,              desc = "Close all folds" },
        { "zr", function() require("ufo").openFoldsExceptKinds() end,       desc = "Open folds except kinds" },
        { "zm", function() require("ufo").closeFoldsWith() end,             desc = "Close folds with" },
        { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek folded lines" },
    },
    opts = {
        provider_selector = function(bufnr, filetype, buftype)
            -- Use LSP as primary provider, fallback to treesitter, then indent
            return { "lsp", "treesitter", "indent" }
        end,
        -- Customize fold text display
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (" 󰁂 %d lines"):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0

            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end

            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end,
        -- Preview configuration
        preview = {
            win_config = {
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:Normal",
                winblend = 0,
                maxheight = 20,
            },
            mappings = {
                scrollU = "<C-u>",
                scrollD = "<C-d>",
                jumpTop = "gg",
                jumpBot = "G",
            },
        },
        -- Close fold when cursor leaves
        close_fold_kinds = {},
        -- Enable folding for these filetypes
        enable_get_fold_virt_text = true,
    },
    config = function(_, opts)
        -- Set fold options
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

        require("ufo").setup(opts)

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
                        fg_alt = "#bbbbbb",
                        blue = "#448cbb",
                        comment = "#888888",
                    }
                end

                vim.api.nvim_set_hl(0, "Folded", { fg = colors.fg_alt or "#bbbbbb", bg = "NONE", italic = true })
                vim.api.nvim_set_hl(0, "FoldColumn", { fg = colors.comment or "#888888", bg = "NONE" })
                vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { fg = colors.blue or "#448cbb", bg = "NONE" })
            end,
        })

        -- Trigger initial highlight setup
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
