require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("utils.todo").setup({
  target_file = "todo.md",
  global_file = "~/todo.md"
})


-- theme
require("utils.color_overrides").setup_colorscheme_overrides()
vim.cmd("colorscheme base16-black-metal-gorgoroth")
require("utils.statusline")

vim.lsp.enable {
  "lua_ls",
  "ts_ls",
  "css_ls",
  "clangd",
  "omnisharp",
  "tailwindcss"
}
