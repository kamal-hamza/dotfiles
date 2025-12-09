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
            python = { "ruff" },              -- Fast modern linter
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
                -- Only lint if the buffer is valid and has a filetype
                if vim.api.nvim_buf_is_valid(0) and vim.bo.filetype ~= "" then
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
