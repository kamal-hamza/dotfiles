vim.pack.add({ "https://github.com/abecodes/tabout.nvim" })

require("tabout").setup({
    -- blink.cmp owns <Tab> for snippet jumps and falls back to this mapping
    completion = false,
})
