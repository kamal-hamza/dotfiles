vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

require("lint").linters_by_ft = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    gdscript = { "gdlint" },
    -- bash/sh diagnostics come from bashls, which shells out to shellcheck on
    -- its own when it's on PATH; zsh has no LSP, so `zsh -n` is its only check
    zsh = { "zsh" },
    go = { "golangcilint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function()
        require("lint").try_lint()
    end,
})
