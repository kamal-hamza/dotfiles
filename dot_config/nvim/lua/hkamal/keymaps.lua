-- disable J joining the current line with the next
vim.keymap.set("n", "J", "<Nop>")

-- disable F1 opening help
vim.keymap.set({ "n", "i", "v" }, "<F1>", "<Nop>")

-- toggle termguicolors for the active colorscheme, persisted across restarts
vim.api.nvim_create_user_command(
    "ToggleTermGuiColors",
    function() require("hkamal.theme").toggle_termguicolors() end,
    { desc = "Toggle GUI Colors (termguicolors)" }
)
vim.keymap.set("n", "<leader>tg", "<Cmd>ToggleTermGuiColors<CR>", { desc = "Toggle GUI Colors (termguicolors)" })
