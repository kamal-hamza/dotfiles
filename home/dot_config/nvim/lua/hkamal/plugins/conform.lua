vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

-- on distros that ship both Qt5 and Qt6 dev packages (e.g. Arch with
-- qt5-declarative + qt6-declarative installed side by side), the unversioned
-- "qmlformat" on PATH resolves to the Qt5 build; the Qt6 one only lives at
-- /usr/lib/qt6/bin, unversioned, with no symlink onto PATH
local function qmlformat_cmd()
    if vim.fn.executable("qmlformat6") == 1 then
        return "qmlformat6"
    elseif vim.fn.executable("/usr/lib/qt6/bin/qmlformat") == 1 then
        return "/usr/lib/qt6/bin/qmlformat"
    end
    return "qmlformat"
end

require("conform").setup({
    formatters = {
        qmlformat = { command = qmlformat_cmd() },
    },
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
        qml = { "qmlformat" },
        cs = { "csharpier" },
        gdscript = { "gdformat" },
        zig = { "zigfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        go = { "goimports", "gofumpt" },
        dockerfile = { "dockerfmt" },
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
