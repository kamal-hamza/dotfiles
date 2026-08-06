vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable({
    "emmylua_ls",
    "tsgo",
    "tailwindcss",
    "pyrefly",
    "ruff",
    "rust_analyzer",
    "clangd",
    "taplo",
    "jsonls",
    "roslyn_ls",
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
