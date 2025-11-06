-- Docker project-specific plugins
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "dockerfile" } },
  },
}
