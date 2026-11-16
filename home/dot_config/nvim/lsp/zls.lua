--- @type vim.lsp.Config
return {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'zls.json', 'build.zig.zon', 'build.zig', '.git' },
  workspace_required = false,
  single_file_support = true,
  settings = {
    zls = {
      enable_snippets = true,
      enable_argument_placeholders = true,
      -- runs `zig build` (see build_on_save_args) in the background for
      -- diagnostics beyond what the ast-check pass alone can catch
      enable_build_on_save = true,
      build_on_save_args = {},
      enable_autofix = false,
      warn_style = true,
      highlight_global_var_declarations = true,
      skip_std_references = false,
      semantic_tokens = "full",
      enable_inlay_hints = true,
      inlay_hints_show_builtin = true,
      inlay_hints_exclude_single_argument = true,
      inlay_hints_hide_redundant_param_names = false,
      inlay_hints_hide_redundant_param_names_last_token = false,
    },
  },
}
