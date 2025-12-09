return {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false
    },
  },
}
