vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

local function open_split(direction)
    return function(selected, opts)
        if direction == "left" or direction == "right" then
            local prev = vim.o.splitright
            vim.o.splitright = (direction == "right")
            actions.file_vsplit(selected, opts)
            vim.o.splitright = prev
        else
            local prev = vim.o.splitbelow
            vim.o.splitbelow = (direction == "down")
            actions.file_split(selected, opts)
            vim.o.splitbelow = prev
        end
    end
end

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
    actions = {
        files = {
            ["enter"] = actions.file_edit_or_qf,
            ["ctrl-h"] = open_split("left"),
            ["ctrl-j"] = open_split("down"),
            ["ctrl-k"] = open_split("up"),
            ["ctrl-l"] = open_split("right"),
            ["ctrl-t"] = actions.file_tabedit,
            ["alt-q"] = actions.file_sel_to_qf,
            ["alt-Q"] = actions.file_sel_to_ll,
            ["alt-i"] = { fn = actions.toggle_ignore, reuse = true, header = false },
            ["alt-h"] = { fn = actions.toggle_hidden, reuse = true, header = false },
            ["alt-f"] = { fn = actions.toggle_follow, reuse = true, header = false },
        },
    },
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Resume Last Search" })
vim.keymap.set("n", "<leader>ft", function()
    fzf.colorschemes({
        colors = {
            "modus",
            "modus_operandi",
            "modus_vivendi",
            "oxocarbon",
            "koda-dark",
            "koda-light",
            "tokyonight-night",
            "tokyonight-storm",
            "tokyonight-moon",
            "tokyonight-day",
            "kanagawa-wave",
            "kanagawa-dragon",
            "kanagawa-lotus",
            "gruvbox-dark",
            "gruvbox-light",
        },
    })
end, { desc = "Switch Colorscheme" })

vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gh", fzf.git_bcommits, { desc = "Git Buffer Commits" })
vim.keymap.set("n", "<leader>gt", fzf.git_stash, { desc = "Git Stash" })

vim.keymap.set("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<leader>db", "<Cmd>bdelete<CR>", { desc = "Delete Buffer" })
