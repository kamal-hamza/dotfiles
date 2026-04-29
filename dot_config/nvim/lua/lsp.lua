vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-vsnip",
  "https://github.com/hrsh7th/vim-vsnip",
  "https://github.com/onsails/lspkind.nvim",
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
    "tinymist"
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

-- nvim cmp
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
  completion = {
    autocomplete = false,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = lspkind.cmp_format({
      mode = 'symbol',
      show_labelDetails = true,
      maxwidth = 50,
      ellipsis_char = '...',
      menu = {
        nvim_lsp = "[LSP]",
        vsnip    = "[Snip]",
        buffer   = "[Buf]",
        path     = "[Path]",
      }
    }),
  },
  snippet = {
    expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-x><C-o>'] = cmp.mapping.complete(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-g>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  }),
})

-- language server configuration
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = {
  "vimls",
  "pyrefly",
  "rust_analyzer",
  "zls",
  "ts_ls"
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
