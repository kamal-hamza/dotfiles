vim.pack.add({
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

local oil = require("oil")

-- replaces netrw: full-window `ls -l` style listing (icon, permissions,
-- size, mtime, name) with dotfiles shown
oil.setup({
    default_file_explorer = true,
    columns = {
        "icon",
        "permissions",
        "size",
        { "mtime", format = "%b %d %H:%M" },
    },
    win_options = {
        signcolumn = "yes",
        number = true,
        relativenumber = true,
    },
    view_options = {
        show_hidden = true,
    },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>ee", function()
    if vim.bo.filetype == "oil" then
        oil.close()
    else
        oil.open()
    end
end, { desc = "Toggle Explorer" })
