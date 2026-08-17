-- live-reload files edited outside nvim (AI tools, another editor, etc.)
-- watches each real file on disk and checktime's it the instant it changes,
-- instead of waiting for FocusGained/CursorHold to poll (see options.lua)
local group = vim.api.nvim_create_augroup("hkamal_filewatch", { clear = true })
local watchers = {}

local function stop_watch(bufnr)
	local handle = watchers[bufnr]
	if handle then
		handle:stop()
		watchers[bufnr] = nil
	end
end

local function start_watch(bufnr)
	stop_watch(bufnr)

	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" or vim.bo[bufnr].buftype ~= "" then
		return
	end
	if not vim.uv.fs_stat(name) then
		return
	end

	local handle = vim.uv.new_fs_event()
	watchers[bufnr] = handle

	handle:start(name, {}, function(err)
		if err then
			return
		end
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd("checktime")
				end)
			end
		end)
	end)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufFilePost" }, {
	group = group,
	callback = function(args)
		start_watch(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
	group = group,
	callback = function(args)
		stop_watch(args.buf)
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		for bufnr in pairs(watchers) do
			stop_watch(bufnr)
		end
	end,
})
