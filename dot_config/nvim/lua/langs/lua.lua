local dap = require("dap")
local mason_nvim_dap = require("mason-nvim-dap")
mason_nvim_dap.setup({
  automatic_installation = true,
  ensure_installed = {
    "lua"
  }
})

dap.adapters["local-lua"] = {
  type = "executable",
  command = "node",
  args = {
    "/Users/hkamal/.local/share/local-lua-debugger-vscode/extension/debugAdapter.js"
  },
  enrich_config = function(config, on_config)
    if not config["extensionPath"] then
      local c = vim.deepcopy(config)
      -- 💀 If this is missing or wrong you'll see
      -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
      c.extensionPath = vim.fn.expand("~/.local/share/local-lua-debugger-vscode")
      on_config(c)
    else
      on_config(config)
    end
  end,
}

dap.configurations.lua = {
  {
    type = "local-lua",
    request = "launch",
    name = "Launch Lua file",
    program = function()
      return vim.fn.input('Path to Lua file: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
    args = {},
  }
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "vim", "regex", "lua", "bash" } },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
