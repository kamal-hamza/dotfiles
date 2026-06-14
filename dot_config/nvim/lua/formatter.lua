local conform = require("conform")

local formatters_by_ft = {
	python = { "isort", "ruff_format" },
	javascript = { "prettierd", "prettier" },
	typescript = { "prettierd", "prettier" },
	javascriptreact = { "prettierd", "prettier" },
	typescriptreact = { "prettierd", "prettier" },
	lua = { "stylua" },
	c = { "clang_format" },
	cpp = { "clang_format" },
	h = { "clang_format" },
	hpp = { "clang_format" },
	rust = { "rustfmt" },
	zig = { "zigfmt" },
	vim = { "vim_formatter" },
	typst = {}, -- LSP formatting only
	json = { "prettierd", "prettier", "jq" },
	yaml = { "yamlfmt", "prettier" },
	toml = { "taplo" },
	bash = { "shfmt" },
	sh = { "shfmt" },
	zsh = { "shfmt" },
	markdown = { "prettierd", "prettier" },
	markdown_inline = { "prettierd", "prettier" },
	css = { "prettierd", "prettier" },
	scss = { "prettierd", "prettier" },
	less = { "prettierd", "prettier" },
	html = { "prettierd", "prettier" },
	sql = { "sqlfluff", "sqlfmt" },
	go = { "gofmt", "goimports" },
	java = { "google_java_format" },
	xml = { "xmlformat" },
}

conform.setup({
	formatters_by_ft = formatters_by_ft,
	formatters = {
		stylua = {
			prepend_args = { "--indent-width", "2" },
		},
		rustfmt = {
      args = { "--emit=stdout" },
		},
		shfmt = {
			prepend_args = { "-i", "2" },
		},
		prettier = {
			prepend_args = { "--tab-width", "2", "--use-tabs", "false" },
		},
		prettierd = {
			prepend_args = { "--tab-width", "2", "--use-tabs", "false" },
		},
	},
	format_on_save = nil, -- Disable auto-format on save; use command instead
	format_after_save = nil,
})

local function format_buffer()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local filetype = vim.bo.filetype

	-- Check if any formatters are configured for this filetype
	local formatters = formatters_by_ft[filetype] or {}
	local has_formatters = #formatters > 0

	-- Try conform first (with lsp_fallback = false)
	if has_formatters then
		local ok, err = pcall(function()
			conform.format({
				lsp_fallback = false,
				async = false,
				timeout_ms = 2000,
			})
		end)
		if ok then
			return
		end
	end

	-- If no formatter available or conform failed, try LSP
	if #clients > 0 then
		local ok = pcall(function()
			vim.lsp.buf.format({
				async = false,
				timeout_ms = 2000,
			})
		end)
		if ok then
			vim.notify("No formatter configured, using LSP formatting", vim.log.levels.WARN)
			return
		end
	end

	-- If no formatter and no LSP, use Neovim's default formatting (indentation)
	vim.notify("No formatter or LSP available, using Neovim default formatting", vim.log.levels.WARN)

	-- Use Neovim's built-in indent operator
	-- gg = go to top, = = indent operator, G = motion to end
	vim.cmd("normal! gg=G")
end

-- Create Format command
vim.api.nvim_create_user_command("Format", function()
	format_buffer()
end, {
	desc = "Format buffer: formatter → LSP → Neovim default",
})

-- Also create FormatSelective for range formatting
vim.api.nvim_create_user_command("FormatRange", function()
	local start_line = vim.fn.line("'<") - 1
	local end_line = vim.fn.line("'>")

	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 2000,
		range = {
			["start"] = { start_line, 0 },
			["end"] = { end_line, -1 },
		},
	})
end, {
	desc = "Format selected range using formatter or LSP",
	range = true,
})

-- Return module for potential reuse
return {
	format_buffer = format_buffer,
}
