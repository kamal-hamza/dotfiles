vim.pack.add({ "https://github.com/akinsho/toggleterm.nvim" })

require("toggleterm").setup({
    direction = "float",
    float_opts = {
        border = "single",
    },
    open_mapping = [[<leader>tt]],
    insert_mappings = false,
    terminal_mappings = false,
    shade_terminals = false,
    start_in_insert = true,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "toggleterm",
    callback = function(event)
        vim.keymap.set("t", "<Esc>", "<Cmd>ToggleTerm<CR>", { buffer = event.buf, desc = "Close Terminal" })
    end,
})
