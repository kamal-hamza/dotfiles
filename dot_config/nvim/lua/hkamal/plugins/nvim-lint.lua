vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

-- on distros that ship both Qt5 and Qt6 dev packages (e.g. Arch with
-- qt5-declarative + qt6-declarative installed side by side), the unversioned
-- "qmllint" on PATH resolves to the Qt5 build; the Qt6 one only lives at
-- /usr/lib/qt6/bin, unversioned, with no symlink onto PATH
local function qmllint_cmd()
    if vim.fn.executable("qmllint6") == 1 then
        return "qmllint6"
    elseif vim.fn.executable("/usr/lib/qt6/bin/qmllint") == 1 then
        return "/usr/lib/qt6/bin/qmllint"
    end
    return "qmllint"
end

-- qmllint has no nvim-lint linter built in, and its --json output doesn't
-- fit the plain errorformat/pattern parsers, so it needs a hand-rolled one:
-- everything (syntax errors included) comes back as one "warnings" array
-- per file, with 1-indexed line/column and a "type" of "warning" or "error"
require("lint").linters.qmllint = {
    cmd = qmllint_cmd(),
    stdin = false,
    append_fname = true,
    args = { "--json", "-" },
    ignore_exitcode = true,
    parser = function(output)
        local diagnostics = {}
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded.files then
            return diagnostics
        end

        local severities = {
            warning = vim.diagnostic.severity.WARN,
            error = vim.diagnostic.severity.ERROR,
        }

        for _, file in ipairs(decoded.files) do
            for _, warning in ipairs(file.warnings or {}) do
                table.insert(diagnostics, {
                    lnum = warning.line - 1,
                    col = warning.column - 1,
                    end_lnum = warning.line - 1,
                    end_col = warning.column - 1 + (warning.length or 0),
                    severity = severities[warning.type] or vim.diagnostic.severity.WARN,
                    message = warning.message,
                    source = "qmllint",
                    code = warning.id,
                })
            end
        end

        return diagnostics
    end,
}

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
    dockerfile = { "hadolint" },
    css = { "stylelint" },
    scss = { "stylelint" },
    qml = { "qmllint" },
}

-- actionlint only understands github workflow yaml, not yaml in general, so
-- it can't live in linters_by_ft.yaml without flooding every other yaml file
-- with false positives; scope it to .github/workflows/*.yml instead
local function is_github_workflow(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    return name:match("%.github/workflows/[^/]+%.ya?ml$") ~= nil
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function(args)
        require("lint").try_lint()
        if is_github_workflow(args.buf) then
            require("lint").try_lint("actionlint")
        end
    end,
})
