vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  { src = "https://github.com/saghen/blink.cmp.git", version = vim.version.range("*") },
})

-- mason
local mason = require("mason")
mason.setup()

-- mason tool installer
local mason_tool_installer = require("mason-tool-installer")
mason_tool_installer.setup({
  ensure_installed = {
    -- LSPs
    "vim-language-server",
    "lua-language-server",
    "pyrefly",
    "rust-analyzer",
    "typescript-language-server",
    "eslint-lsp",
    "tinymist",
    "clangd",

    -- Formatters
    "stylua", -- Lua
    "prettierd", -- JavaScript, TypeScript, JSON, YAML, CSS, Markdown, HTML
    "prettier", -- JavaScript, TypeScript, JSON, YAML, CSS, Markdown, HTML
    "clang-format", -- C/C++
    "isort", -- Python imports
    "ruff", -- Python linter/formatter
    "shfmt", -- Shell/Bash
    "yamlfmt", -- YAML
    "taplo", -- TOML
    "jq", -- JSON
    "sqlfluff", -- SQL
  },
})

-- nvim lsp config

-- lua specific config
vim.lsp.config("lua_ls", {
  filetypes = { "lua" },
  root_markers = { ".git", "init.lua" },
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
})

-- tinymist specific config
vim.lsp.config("tinymist", {
  filetypes = { "typst" },
})

-- language server configuration
local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  "vimls",
  "pyrefly",
  "rust_analyzer",
  "zls",
  "ts_ls",
  "clangd",
}

-- lua vim override
local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      },
    },
  },
  clangd = {
    offset_encoding = "utf-8",
  },
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
  completion = {
    menu = {
      border = "none",
      min_width = 60,
    },
  },
  appearance = {
    kind_icons = {
      Text = "󰉿",
      Method = "󰊕",
      Function = "󰊕",
      Constructor = "󰒓",

      Field = "󰜢",
      Variable = "󰆦",
      Property = "󰖷",
      Class = "󱡠",
      Interface = "󱡠",
      Struct = "󱡠",
      Module = "󰅩",
      Unit = "󰪚",
      Value = "󰦨",
      Enum = "󰦨",
      EnumMember = "󰦨",
      Keyword = "󰻾",
      Constant = "󰏿",
      Snippet = "󱄽",
      Color = "󰏘",
      File = "󰈔",
      Reference = "󰬲",
      Folder = "󰉋",
      Event = "󱐋",
      Operator = "󰪚",
      TypeParameter = "󰬛",
    },
  },
  signature = {
    enabled = true,
    window = {
      border = "rounded",
      show_documentation = false,
    },
  },
})
