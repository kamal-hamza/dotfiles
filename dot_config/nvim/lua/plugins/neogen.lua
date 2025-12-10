return {
    "danymat/neogen",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "L3MON4D3/LuaSnip",
    },
    cmd = "Neogen",
    keys = {
        {
            "<leader>nf",
            function()
                require("neogen").generate({ type = "func" })
            end,
            desc = "Generate Function Annotation",
        },
        {
            "<leader>nc",
            function()
                require("neogen").generate({ type = "class" })
            end,
            desc = "Generate Class Annotation",
        },
        {
            "<leader>nt",
            function()
                require("neogen").generate({ type = "type" })
            end,
            desc = "Generate Type Annotation",
        },
        {
            "<leader>nF",
            function()
                require("neogen").generate({ type = "file" })
            end,
            desc = "Generate File Annotation",
        },
        {
            "<leader>ng",
            function()
                require("neogen").generate()
            end,
            desc = "Generate Annotation (auto-detect)",
        },
    },
    opts = {
        enabled = true,
        input_after_comment = true,
        snippet_engine = "luasnip",
        enable_placeholders = true,
        placeholders_text = {
            ["description"] = "[TODO:description]",
            ["tparam"] = "[TODO:parameter]",
            ["parameter"] = "[TODO:parameter]",
            ["return"] = "[TODO:return]",
            ["class"] = "[TODO:class]",
            ["throw"] = "[TODO:throw]",
            ["varargs"] = "[TODO:varargs]",
            ["type"] = "[TODO:type]",
            ["attribute"] = "[TODO:attribute]",
            ["args"] = "[TODO:args]",
            ["kwargs"] = "[TODO:kwargs]",
        },
        languages = {
            -- Python - Google style docstrings
            python = {
                template = {
                    annotation_convention = "google_docstrings",
                },
            },
            -- TypeScript/JavaScript - JSDoc
            typescript = {
                template = {
                    annotation_convention = "jsdoc",
                },
            },
            javascript = {
                template = {
                    annotation_convention = "jsdoc",
                },
            },
            typescriptreact = {
                template = {
                    annotation_convention = "jsdoc",
                },
            },
            javascriptreact = {
                template = {
                    annotation_convention = "jsdoc",
                },
            },
            -- Lua - LDoc
            lua = {
                template = {
                    annotation_convention = "ldoc",
                },
            },
            -- Rust - Rustdoc
            rust = {
                template = {
                    annotation_convention = "rustdoc",
                },
            },
            -- Go - GoDoc
            go = {
                template = {
                    annotation_convention = "godoc",
                },
            },
            -- C/C++ - Doxygen
            c = {
                template = {
                    annotation_convention = "doxygen",
                },
            },
            cpp = {
                template = {
                    annotation_convention = "doxygen",
                },
            },
            -- C# - XML documentation
            cs = {
                template = {
                    annotation_convention = "xmldoc",
                },
            },
            -- Java - JavaDoc
            java = {
                template = {
                    annotation_convention = "javadoc",
                },
            },
            -- PHP - PHPDoc
            php = {
                template = {
                    annotation_convention = "phpdoc",
                },
            },
            -- Ruby - YARD
            ruby = {
                template = {
                    annotation_convention = "yard",
                },
            },
        },
    },
    config = function(_, opts)
        require("neogen").setup(opts)

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
                        comment = "#888888",
                        blue = "#448cbb",
                        orange = "#D4B87B",
                    }
                end

                -- Neogen annotation highlights
                vim.api.nvim_set_hl(0, "NeogenParameter", { fg = colors.orange or "#D4B87B", italic = true })
                vim.api.nvim_set_hl(0, "NeogenType", { fg = colors.blue or "#448cbb", italic = true })
                vim.api.nvim_set_hl(0, "NeogenComment", { fg = colors.comment or "#888888", italic = true })
            end,
        })

        -- Trigger initial highlight setup
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end,
}
