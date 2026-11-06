vim.pack.add({ "https://github.com/kamal-hamza/conduit.nvim" })

require("conduit").setup({
    default_agent = "claude",
    -- Inline edits run in a fresh session each time; keep them fast.
    inline = {
        options = { model = "sonnet", effort = "low" },
    },
})

vim.keymap.set("n", "<leader>at", "<Cmd>Conduit toggle<CR>", { desc = "Conduit: toggle chat" })
vim.keymap.set("n", "<leader>an", "<Cmd>Conduit new<CR>", { desc = "Conduit: new chat" })
vim.keymap.set("n", "<leader>am", "<Cmd>Conduit model<CR>", { desc = "Conduit: pick model" })
vim.keymap.set("n", "<leader>ar", "<Cmd>Conduit effort<CR>", { desc = "Conduit: pick reasoning effort" })
vim.keymap.set("n", "<leader>ao", "<Cmd>Conduit option<CR>", { desc = "Conduit: session options" })
vim.keymap.set("n", "<leader>ax", "<Cmd>Conduit cancel<CR>", { desc = "Conduit: cancel" })
-- Edit or ask about the selection (or current line); the agent decides, <C-t> forces a mode.
vim.keymap.set({ "n", "v" }, "<leader>ai", ":Conduit inline<CR>", { desc = "Conduit: inline edit or question" })
vim.keymap.set("v", "<leader>as", ":Conduit add<CR>", { desc = "Conduit: add selection to prompt" })
