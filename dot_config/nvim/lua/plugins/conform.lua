return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
    },
    opts = {
        formatters_by_ft = {
            -- Lua
            lua = { "stylua" },

            -- Python (ruff for formatting and import sorting)
            python = { "ruff_organize_imports", "ruff_format" },

            -- JavaScript/TypeScript/Web
            javascript = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            vue = { "prettierd", "prettier", stop_after_first = true },
            svelte = { "prettierd", "prettier", stop_after_first = true },

            -- CSS/HTML
            css = { "prettierd", "prettier", stop_after_first = true },
            scss = { "prettierd", "prettier", stop_after_first = true },
            html = { "prettierd", "prettier", stop_after_first = true },

            -- JSON/YAML/Markdown
            json = { "prettierd", "prettier", stop_after_first = true },
            jsonc = { "prettierd", "prettier", stop_after_first = true },
            yaml = { "prettierd", "prettier", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
            graphql = { "prettierd", "prettier", stop_after_first = true },

            -- Systems Programming
            rust = { "rustfmt" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            go = { "goimports" },  -- goimports handles both imports and formatting
            cs = { "csharpier" },

            -- Shell
            sh = { "shfmt" },
            bash = { "shfmt" },
            zsh = { "shfmt" },

            -- Other
            toml = { "taplo" },

            -- Fallback: trim whitespace for all files
            ["_"] = { "trim_whitespace" },
        },

        -- Format on save configuration
        format_on_save = function(bufnr)
            -- Disable autoformat on certain filetypes
            local ignore_filetypes = { "sql", "java", "text" }
            if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
                return
            end

            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end

            return {
                timeout_ms = 1000,
                lsp_fallback = true,
                quiet = false,
            }
        end,

        -- Formatter-specific configuration
        formatters = {
            shfmt = {
                prepend_args = { "-i", "2", "-ci" }, -- 2-space indent, indent switch cases
            },
            ruff_format = {
                prepend_args = { "--line-length", "100" },
            },
        },
    },

    init = function()
        -- Format on save toggle commands
        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                -- FormatDisable! will disable formatting globally
                vim.g.disable_autoformat = true
                vim.notify("Disabled format-on-save globally", vim.log.levels.INFO)
            else
                vim.b.disable_autoformat = true
                vim.notify("Disabled format-on-save for this buffer", vim.log.levels.INFO)
            end
        end, {
            desc = "Disable autoformat-on-save",
            bang = true,
        })

        vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
            vim.notify("Enabled format-on-save", vim.log.levels.INFO)
        end, {
            desc = "Re-enable autoformat-on-save",
        })

        -- Show formatting info
        vim.api.nvim_create_user_command("FormatInfo", function()
            vim.cmd("ConformInfo")
        end, {
            desc = "Show ConformInfo",
        })
    end,
}
