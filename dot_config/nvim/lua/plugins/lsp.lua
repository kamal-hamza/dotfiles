-- =============================================================================
-- LSP — mason + mason-tool-installer + nvim-lspconfig
-- =============================================================================

-- mason: LSP/formatter/linter installer
require("mason").setup()

-- mason-tool-installer: ensure tools are always present
require("mason-tool-installer").setup({
  ensure_installed = {
    -- LSPs
    "vim-language-server",
    "lua-language-server",
    "pyrefly",
    "rust-analyzer",
    "typescript-language-server",
    "eslint-lsp",
    "svelte-language-server",
    "tinymist",
    "clangd",
    "jdtls",

    -- Formatters
    "stylua",        -- Lua
    "prettierd",     -- JS/TS/JSON/YAML/CSS/Markdown/HTML
    "prettier",      -- JS/TS/JSON/YAML/CSS/Markdown/HTML
    "clang-format",  -- C/C++
    "isort",         -- Python imports
    "ruff",          -- Python linter/formatter
    "shfmt",         -- Shell/Bash
    "yamlfmt",       -- YAML
    "taplo",         -- TOML
    "jq",            -- JSON
    "sqlfluff",      -- SQL
  },
})

-- Per-server overrides for non-default settings
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

-- Lua LS root markers
vim.lsp.config("lua_ls", {
  filetypes = { "lua" },
  root_markers = { ".git", "init.lua" },
  settings = server_configs.lua_ls.settings,
})

-- Tinymist (Typst)
vim.lsp.config("tinymist", {
  filetypes = { "typst" },
})

-- Enable servers with blink.cmp capabilities
local capabilities = require("blink.cmp").get_lsp_capabilities()

local servers = {
  "vimls",
  "pyrefly",
  "rust_analyzer",
  "zls",
  "ts_ls",
  "clangd",
  "jdtls",
  "lua_ls",
  "svelte",
  "tinymist",
}

for _, server in ipairs(servers) do
  local config = server_configs[server] or {}
  config.capabilities = capabilities
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
