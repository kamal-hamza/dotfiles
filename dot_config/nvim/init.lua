-- Add local dark theme to runtimepath (must be very early)
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/colors")

-- load options
require("options")
-- load keymaps
require("keymaps")
-- load commands
require("commands")
-- load plugins
require("plugins")
-- load lsp
require("lsp")
-- load statusline
require("statusline")
