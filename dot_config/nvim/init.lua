-- Add local dark theme to runtimepath (must be very early)
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/colors")

-- =============================================================================
-- Core
-- =============================================================================
require("core.options")
require("core.keymaps")
require("core.commands")

-- =============================================================================
-- Plugins
-- =============================================================================
-- Declare all plugins first so they are available before any setup() calls
require("plugins.pack")

-- Editing helpers
require("plugins.autopairs")
require("plugins.surround")

-- File navigation
require("plugins.oil")
require("plugins.telescope")

-- Treesitter (native, no plugin)
require("plugins.treesitter")

-- LSP + completion
require("plugins.lsp")
require("plugins.blink")

-- Formatting
require("plugins.conform")

-- Diagnostics
require("plugins.trouble")

-- Git
require("plugins.gitsigns")
require("plugins.neogit")
require("plugins.diffview")

-- Navigation
require("plugins.flash")

-- UI
require("plugins.heirline")
require("plugins.smear")
require("plugins.render-markdown")

-- Undo history
require("plugins.undotree")

-- Outline / symbols
require("plugins.outline")

-- Note taking
require("plugins.obsidian")

-- Colorscheme (last, so highlight groups from plugins are already set)
require("plugins.theme")

-- debug nvim plugin
vim.cmd.packadd("launch.nvim")

require("launch")
