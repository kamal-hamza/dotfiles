return {
    "neoclide/coc.nvim",
    branch = "release",
    event = "InsertEnter",
    build = "npm ci",
    config = function()
        -- Coc extensions to install automatically
        vim.g.coc_global_extensions = {
            "coc-json",
            "coc-tsserver",
            "coc-html",
            "coc-css",
            "coc-pyright",
            "coc-lua",
            "coc-snippets",
            "coc-yaml",
            "coc-sh",
            "coc-tailwindcss",
            "coc-emmet",
            "coc-eslint",
            "coc-prettier",
        }

        -- Use Tab for trigger completion and navigate
        vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<TAB>"', { expr = true, silent = true })
        vim.keymap.set("i", "<S-TAB>", 'coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"', { expr = true, silent = true })

        -- Make <CR> to accept selected completion item
        vim.keymap.set("i", "<CR>", 'coc#pum#visible() ? coc#pum#confirm() : "<C-g>u<CR><c-r>=coc#on_enter()<CR>"', {
            expr = true,
            silent = true,
        })

        -- Use <c-space> to trigger completion
        vim.keymap.set("i", "<c-space>", "coc#refresh()", { expr = true, silent = true })

        -- Scroll float windows/popups
        vim.keymap.set("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"',
            { expr = true, silent = true })
        vim.keymap.set("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"',
            { expr = true, silent = true })
        vim.keymap.set("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"',
            { expr = true, silent = true })
        vim.keymap.set("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"',
            { expr = true, silent = true })

        -- Highlight symbol under cursor
        vim.api.nvim_create_augroup("CocGroup", {})
        vim.api.nvim_create_autocmd("CursorHold", {
            group = "CocGroup",
            command = "silent call CocActionAsync('highlight')",
            desc = "Highlight symbol under cursor on CursorHold",
        })
    end,
}
