require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("utils.todo").setup({
    target_file = "todo.md",
    global_file = "~/todo.md"
})


-- theme overrides
require("plugins.themes.soft-focus-light").setup()
vim.cmd('colorscheme soft-focus-light')

vim.lsp.enable {
    "lua_ls",
    "ts_ls",
    "css_ls",
    "clangd",
    "omnisharp",
    "tailwindcss"
}
