local Lsp = require("utils.lsp")
return {
  cmd = { "vscode-css-language-server", "--stdio" },
  on_attach = Lsp.on_attach,
  filetypes = { "css", "scss", "less" },
  root_markers = {
    "package.json",
    ".git",
    "style.css",
    "styles.css",
    "scss",
    "less"
  },
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    }
  },
  init_options = {
    provideFormatter = true
  }
}
