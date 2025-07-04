return {
  "folke/lazydev.nvim",
  opts = {
    library = {
      { "nvim-dap-ui" },
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim",        words = { "Snacks" } },
      { path = "lazy.nvim",          words = { "LazyVim" } },
    },
  },
  optional = true,
}
