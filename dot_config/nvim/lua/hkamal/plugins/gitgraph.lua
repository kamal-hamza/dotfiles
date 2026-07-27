vim.pack.add({ "https://github.com/isakbm/gitgraph.nvim" })

require("gitgraph").setup({
    symbols = {
        merge_commit = "M",
        commit = "*",
    },
})
