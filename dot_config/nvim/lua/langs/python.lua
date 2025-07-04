return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("/opt/anaconda3/envs/debug/bin/python")
      require('dap-python').test_runner = 'pytest'
    end
  }
}
