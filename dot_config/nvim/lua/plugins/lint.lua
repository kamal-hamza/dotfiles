return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        -- Configure linters by filetype
        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            python = { "ruff" }, -- Fast modern linter
            -- lua = { "luacheck" },          -- Disabled: requires luarocks
            markdown = { "markdownlint" },
            dockerfile = { "hadolint" },
            yaml = { "yamllint" },
            sh = { "shellcheck" },
            bash = { "shellcheck" },
        }

        -- Create autocommand to trigger linting
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
            group = lint_augroup,
            callback = function()
                -- Filetypes to exclude from linting
                local excluded_filetypes = {
                    "toggleterm",
                    "terminal",
                    "TelescopePrompt",
                    "oil",
                    "help",
                    "fugitive",
                    "gitcommit",
                    "lazy",
                    "mason",
                    "",
                }

                -- Check if current filetype is excluded
                local current_ft = vim.bo.filetype
                for _, ft in ipairs(excluded_filetypes) do
                    if current_ft == ft then
                        return
                    end
                end

                -- Only lint if the buffer is valid and has a filetype
                if vim.api.nvim_buf_is_valid(0) and current_ft ~= "" then
                    lint.try_lint()
                end
            end,
        })

        -- Manual lint trigger
        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
