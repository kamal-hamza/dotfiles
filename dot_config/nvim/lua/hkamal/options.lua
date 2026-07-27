-- leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- line numbers
vim.opt.number = false 
vim.opt.relativenumber = false 
-- tabs and spaces
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
-- clipboard
vim.opt.clipboard = "unnamedplus"
-- search casing
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- undo history
vim.opt.undofile = true
vim.opt.swapfile = false
-- scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
-- splits
vim.opt.splitright = true
vim.opt.splitbelow = true
-- ui
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.linespace = 3
-- completion
vim.opt.completeopt = "menu,menuone,noselect,popup"
-- folds
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
-- responsiveness
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
-- diagnostics
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	float = { source = "if_many" },
	jump = { float = true },
	virtual_text = {
		spacing = 2,
		prefix = "●",
	},
	signs = true,
	underline = true,
})
