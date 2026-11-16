vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/kawre/leetcode.nvim",
})

-- only takes over the UI when launched as `nvim leetcode.nvim` (or via :Leet);
-- the html treesitter parser it needs for problem descriptions is in treesitter.lua
require("leetcode").setup({
    arg = "leetcode.nvim",
    lang = "cpp",
    -- solutions go in their own repo (cloned via .chezmoiexternal.toml); the
    -- session cookie stays in the default cache dir, outside of it
    storage = {
        home = vim.fn.expand("~/Code/leetcode-nvim"),
    },
    picker = { provider = "fzf-lua" },
    -- needs image.nvim, loaded before this in init.lua
    image_support = true,
})
