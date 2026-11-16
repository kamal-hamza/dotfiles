--- @type vim.lsp.Config
return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.emmyrc.json',
    '.luacheckrc',
    '.git',
  },
  workspace_required = false,
  single_file_support = true,
  settings = {
    -- emmylua_ls pulls configuration via `workspace/configuration` under the
    -- "emmylua" scope, using the same shape as `.emmyrc.json` -- NOT the
    -- `Lua.*` shape that lua_ls/sumneko expects.
    emmylua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        -- ships Neovim's own LuaCATS/EmmyLua annotations for the `vim` global
        library = { vim.env.VIMRUNTIME .. "/lua" },
      },
      codeAction = {
        insertSpace = true,
      },
      strict = {
        typeCall = true,
        arrayIndex = false,
        metaOverrideFileDefine = true,
      },
      diagnostics = {
        enable = true,
        globals = { "vim" },
        disable = {
          "unnecessary-if",
          "unnecessary-assert",
        },
        severity = {
          ["param-type-mismatch"] = "error",
          ["return-type-mismatch"] = "error",
          ["assign-type-mismatch"] = "error",
          ["type-not-found"] = "error",
        },
      },
      hint = {
        enable = true,
        paramHint = false,
        indexHint = false,
        localHint = true,
        overrideHint = true,
        metaCallHint = true,
      },
    },
  },
}
