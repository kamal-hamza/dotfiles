vim.pack.add({
    "https://github.com/akinsho/bufferline.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

require("bufferline").setup({
    options = {
        mode = "buffers",
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
            { filetype = "NvimTree", text = "Explorer", highlight = "Directory", text_align = "left" },
        },
    },
})

vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>db", "<Cmd>bdelete<CR>", { desc = "Delete Buffer" })
