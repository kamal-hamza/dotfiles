vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  { src = "https://github.com/saghen/blink.cmp.git", version = vim.version.range("*") },
})

-- mason
local mason = require("mason")
mason.setup()

-- zls to version 15 for zig 15
local registry = require("mason-registry")
local zls = registry.get_package("zls")

if zls:is_installed() then
  zls:uninstall()
end

zls:install({ version = "0.15.0" })

-- mason tool installer
local mason_tool_installer = require("mason-tool-installer")
mason_tool_installer.setup({
  ensure_installed = {
    "vim-language-server",
    "lua-language-server",
    "pyrefly",
    "zls",
    "rust-analyzer",
    "typescript-language-server",
    "eslint-lsp",
    "tinymist",
    "clangd"
  },
})

-- nvim lsp config

-- lua specific config
vim.lsp.config("lua_ls", {
  filetypes = { 'lua' },
  root_markers = { '.git', 'init.lua' },
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) }
    }
  }
})

-- tinymist specific config
vim.lsp.config("tinymist", {
  filetypes = {"typst"},
})

-- language server configuration
local capabilities = require('blink.cmp').get_lsp_capabilities()

local servers = {
  "vimls",
  "pyrefly",
  "rust_analyzer",
  "zls",
  "ts_ls",
  "clangd"
}

-- lua vim override
local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { 'vim' } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) }
      }
    }
  },
  clangd = {
    offset_encoding = "utf-8",
  }
}

table.insert(servers, "lua_ls")
table.insert(servers, "tinymist")

for _, server in ipairs(servers) do
  local config = server_configs[server] or {}
  config.capabilities = capabilities
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- blink.cmp
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide" },
    ["<C-y>"] = { "select_and_accept" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  appearance = {
    use_nvim_cmp_as_default_menu = false,
    nerd_font_variant = "mono",
    kind_icons = {
      Text = "󰉿",
      Method = "󰊕",
      Function = "󰊕",
      Constructor = "󰒓",
      Field = "󰇽",
      Variable = "󰂡",
      Class = "󰠱",
      Interface = "󰙅",
      Module = "󰕳",
      Property = "󰖷",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "󰎨",
      Keyword = "󰌋",
      Snippet = "󰩌",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "󰎪",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "󰕘",
      Operator = "󰆕",
      TypeParameter = "󰅲",
    },
  },
  completion = {
    menu = {
      border = "rounded",
      winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
      scrollbar = true,
      scrolloff = 2,
      direction_priority = { "s", "n" },
      auto_show = true,
      max_height = 10,
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        components = {
          kind_icon = {
            text = function(ctx)
              return ctx.kind_icon .. " "
            end,
          },
          label = {
            width = { max = 60 },
          },
          label_description = {
            width = { max = 60 },
            text = function(ctx)
              if ctx.label_description then
                return " " .. ctx.label_description
              end
              return ""
            end,
          },
        },
      },
    },
    documentation = {
      auto_show = false,
      window = { border = "none" },
    },
    ghost_text = { enabled = true },
    list = { selection = { preselect = false, auto_insert = false } },
  },
  sources = {
    default = { "lsp", "path", "buffer" },
  },
})
