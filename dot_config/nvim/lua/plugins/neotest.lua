return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: Run File" },
    { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Test: Run All Test Files" },
    { "<leader>tr", function() require("neotest").run.run() end, desc = "Test: Run Nearest" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Test: Run Last" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: Toggle Summary" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test: Show Output" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test: Toggle Output Panel" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Test: Stop" },
    { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: Debug Nearest" },
  },
  opts = {
    adapters = {},
    status = { virtual_text = true },
    output = { open_on_run = true },
    quickfix = {
      open = function()
        vim.cmd("Trouble qflist")
      end,
    },
  },
  config = function(_, opts)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    if opts.adapters then
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        if type(name) == "number" then
          if type(config) == "string" then
            config = require(config)
          end
          adapters[#adapters + 1] = config
        elseif config ~= false then
          adapters[#adapters + 1] = require(name)(config)
        end
      end
      opts.adapters = adapters
    end

    require("neotest").setup(opts)
  end,
}
