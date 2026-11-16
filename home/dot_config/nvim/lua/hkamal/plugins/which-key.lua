vim.pack.add({ "https://github.com/folke/which-key.nvim" })

require("which-key").setup({
    delay = 500,
    plugins = {
        marks = false,
        registers = false,
        spelling = { enabled = false },
        presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
        },
    },
})
