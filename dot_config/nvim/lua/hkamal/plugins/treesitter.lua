vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require("nvim-treesitter").setup({})

require("nvim-treesitter").install({
    "lua",
    "vim",
    "vimdoc",
    "bash",
    "zsh",
    "powershell",
    "python",
    "javascript",
    "typescript",
    "tsx",
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
    "gomod",
    "gosum",
    "gowork",
    "toml",
    "gdscript",
    "gdshader",
    "godot_resource",
    "zig",
})

-- the powershell parser is named "powershell" but neovim's filetypes for its
-- file extensions are "ps1"/"psm1"/"psd1", so the two need an explicit link
vim.treesitter.language.register("powershell", { "ps1", "psm1", "psd1" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
