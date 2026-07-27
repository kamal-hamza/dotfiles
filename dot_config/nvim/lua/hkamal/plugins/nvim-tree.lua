-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/nvim-tree/nvim-web-devicons",
})


---@type nvim_tree.config
local config = {
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 30,
    },
    git = {
        show_on_dirs = false,
    },
    renderer = {
        group_empty = true,
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = false,
                git = true,
            },
            web_devicons = {
                file = { enable = true, color = true },
                folder = { enable = true, color = true },
            },
            git_placement = "after",
            glyphs = {
                git = {
                    unstaged = "M",
                    staged = "M",
                    unmerged = "C",
                    renamed = "R",
                    untracked = "U",
                    deleted = "D",
                    ignored = "I",
                },
            },
        },
    },
    filters = {
        dotfiles = true,
    },
}

require("nvim-tree").setup(config)

vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle Explorer" })
