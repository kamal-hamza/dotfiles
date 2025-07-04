return {
  "MoaidHathot/dotnet.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  cond = function()
    return require("utils.project").check_project_condition("dotnet")
  end,
  opts = {
    bootstrap = {
      auto_bootstrap = true,
    },
    project_selection = {
      path_display = "filename_first"
    }
  }
}
