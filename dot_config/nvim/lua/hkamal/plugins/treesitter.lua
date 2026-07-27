vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require("nvim-treesitter").setup({})

require("nvim-treesitter").install({
    "lua",
    "vim",
    "vimdoc",
    "bash",
    "python",
    "javascript",
    "typescript",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
    "html",
    "css",
    "c",
    "cpp",
    "c_sharp",
    "rust",
    "go",
    "toml",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
