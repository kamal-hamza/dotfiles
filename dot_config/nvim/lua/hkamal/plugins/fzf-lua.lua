vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf = require("fzf-lua")

fzf.setup({
    "borderless",
    winopts = {
        height = 0.5,
        width = 0.6,
        preview = {
            hidden = "hidden",
        },
    },
    keymap = {
        builtin = {
            ["<A-p>"] = "toggle-preview",
        },
        fzf = {
            ["alt-p"] = "toggle-preview",
        },
    },
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Resume Last Search" })

vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gh", fzf.git_bcommits, { desc = "Git Buffer Commits" })
vim.keymap.set("n", "<leader>gt", fzf.git_stash, { desc = "Git Stash" })
