vim.pack.add({
    { src = "https://github.com/L3MON4D3/LuaSnip", version = vim.version.range("2.*") },
})

require("luasnip").setup({
    history = true,
    updateevents = "TextChanged,TextChangedI",
})

require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/snippets" })

vim.keymap.set("i", "<C-l>", function()
    local ls = require("luasnip")
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { desc = "Snippet: expand or jump forward" })
