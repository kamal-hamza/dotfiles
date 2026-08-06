vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "ruff_fix", "ruff_format" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        cs = { "csharpier" },
    },
})

vim.api.nvim_create_user_command("Format", function()
    local ok, formatted = pcall(require("conform").format, {
        async = false,
        lsp_format = "fallback",
        timeout_ms = 2000,
    })
    if not ok or not formatted then
        vim.notify("Format: no formatter available for this buffer", vim.log.levels.WARN)
    end
end, { desc = "Format current buffer with conform" })
