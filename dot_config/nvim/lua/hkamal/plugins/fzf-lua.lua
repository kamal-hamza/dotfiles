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

-- Directories excluded from file/grep searches even outside a git repo
-- (where there's no .gitignore to filter them). Still applies with alt-i.
local excluded_dirs = {
    ".git",
    ".jj",
    "node_modules",
    "build",
    "dist",
    "out",
    "target",
    ".next",
    ".nuxt",
    ".svelte-kit",
    ".turbo",
    ".cache",
    "coverage",
    "vendor",
    "__pycache__",
    ".venv",
    "venv",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    ".tox",
    ".gradle",
    ".idea",
    "bin",
    "obj",
    ".zig-cache",
    "zig-out",
}

local fd_excludes, rg_excludes = {}, {}
for _, dir in ipairs(excluded_dirs) do
    table.insert(fd_excludes, "--exclude " .. dir)
    table.insert(rg_excludes, "-g '!" .. dir .. "/'")
end
fd_excludes = table.concat(fd_excludes, " ")
rg_excludes = table.concat(rg_excludes, " ")

fzf.setup({
    files = {
        fd_opts = "--color=never --type f --type l " .. fd_excludes,
        rg_opts = "--color=never --files " .. rg_excludes,
    },
    grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 "
            .. rg_excludes
            .. " -e",
    },
    winopts = {
        height = 0.5,
        width = 0.6,
        border = "rounded",
        preview = {
            hidden = "hidden",
            border = "rounded",
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
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace, { desc = "Project Diagnostics" })
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
            "sonokai-default",
            "sonokai-shusia",
            "sonokai-andromeda",
            "sonokai-atlantis",
            "sonokai-maia",
            "sonokai-espresso",
            "cursor-dark",
            "cursor-dark-midnight",
            "onedark",
            "onedark_dark",
            "onedark_vivid",
            "onelight",
            "vaporwave",
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
