return {
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("tailwind-tools").setup({
        server = {
          -- Let tailwind-tools manage the LSP setup
          override = true,
        },
        cmp = {
          highlight = "background",
        },
      })
    end,
  }
}
