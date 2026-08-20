vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- fold any diagnostic(s) under the cursor into the hover float, the way
-- Zed's hover tooltip shows diagnostics alongside docs
do
    local default_hover = vim.lsp.handlers["textDocument/hover"]

    vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        local bufnr = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local lnum, col = cursor[1] - 1, cursor[2]

        local diagnostics = vim.tbl_filter(function(d)
            local end_col = math.max(d.end_col or (d.col + 1), d.col + 1)
            return col >= d.col and col < end_col
        end, vim.diagnostic.get(bufnr, { lnum = lnum }))

        if #diagnostics == 0 then
            return default_hover(err, result, ctx, config)
        end

        local lines = {}
        for _, d in ipairs(diagnostics) do
            local severity = vim.diagnostic.severity[d.severity]
            for i, line in ipairs(vim.split(d.message, "\n")) do
                table.insert(lines, (i == 1 and string.format("**%s**: ", severity) or "  ") .. line)
            end
        end

        if result and result.contents then
            table.insert(lines, "---")
            vim.list_extend(lines, vim.lsp.util.convert_input_to_markdown_lines(result.contents))
        end

        config = config or {}
        config.focus_id = "textDocument/hover"
        return vim.lsp.util.open_floating_preview(lines, "markdown", config)
    end
end

vim.lsp.enable({
    "emmylua_ls",
    "tsgo",
    "tailwindcss",
    "pyrefly",
    "ruff",
    "clangd",
    "taplo",
    "jsonls",
    "roslyn_ls",
    "gdscript",
    "zls",
    "bashls",
    "powershell_es",
    "gopls",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local fzf = require("fzf-lua")
        local buf = event.buf
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end

        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
        map("n", "gD", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
        end, "Goto Definition (vsplit)")
        map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
        map("n", "gy", vim.lsp.buf.type_definition, "Goto Type Definition")
        map("n", "gr", fzf.lsp_references, "References")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")

        map("n", "<leader>cc", fzf.lsp_code_actions, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>cs", fzf.lsp_document_symbols, "Document Symbols")
        map("n", "<leader>cw", fzf.lsp_workspace_symbols, "Workspace Symbols")

        map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
        map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
        map("n", "<leader>ce", vim.diagnostic.open_float, "Line Diagnostics")
    end,
})
