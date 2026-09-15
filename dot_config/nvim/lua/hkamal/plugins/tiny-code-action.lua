vim.pack.add({ "https://github.com/rachartier/tiny-code-action.nvim" })

require("tiny-code-action").setup({
    picker = "fzf-lua",
})

vim.keymap.set({ "n", "x" }, "<leader>cc", function()
    require("tiny-code-action").code_action()
end, { desc = "Code Action" })
