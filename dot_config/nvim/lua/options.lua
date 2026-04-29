-- set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Remove line numbers
vim.o.number = false

-- case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

-- sync clipboards
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)

-- vim diagnostics
vim.diagnostic.config({
  serverity_sort = true,
  update_in_insert = false,
  float = { source = "if_many" },
  jump = { float = true },
  virtual_text = {
    spacing = 2,
    prefix = "##",
  },
  signs = true,
  underline = true,
})

-- diable word wrapping on multiple lines
vim.opt.wrap = false
vim.opt.sidescrolloff = 8

-- completion behaviour
vim.opt.completeopt = "menu,menuone,noselect,popup"

-- vim fold levels
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- tabs and spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smarttab = true

-- new split options
vim.opt.splitright = true
vim.opt.splitbelow = true

-- signcolumn
vim.opt.signcolumn = "yes"
