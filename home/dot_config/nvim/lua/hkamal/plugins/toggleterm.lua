vim.pack.add({ "https://github.com/akinsho/toggleterm.nvim" })

require("toggleterm").setup({
    direction = "float",
    float_opts = {
        border = "rounded",
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

-- discard the primary toggleterm terminal and replace it with a fresh one.
-- if it's currently open, close it and open the new one in its place; if it's
-- not open (or was never created), just spawn the replacement in the
-- background so the next <leader>tt gets a clean shell.
vim.api.nvim_create_user_command("RefreshTerminal", function()
    local terms = require("toggleterm.terminal")
    local id = terms.get_toggled_id() or 1
    local term = terms.get(id, true)
    local was_open = term ~= nil and term:is_open()

    if term then term:shutdown() end

    local fresh = terms.get_or_create_term(id)
    if was_open then
        fresh:open()
    else
        fresh:spawn()
    end
end, { desc = "Discard the current terminal and start a fresh one" })
