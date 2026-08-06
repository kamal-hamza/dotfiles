local M = {}

local state_file = vim.fn.stdpath("state") .. "/theme.txt"
local tgc_state_file = vim.fn.stdpath("state") .. "/termguicolors.txt"

function M.save(name)
    local f = io.open(state_file, "w")
    if f then
        f:write(name)
        f:close()
    end
end

function M.load()
    local f = io.open(state_file, "r")
    if not f then
        return nil
    end
    local name = f:read("*l")
    f:close()
    if name == "" then
        return nil
    end
    return name
end

function M.save_termguicolors(value)
    local f = io.open(tgc_state_file, "w")
    if f then
        f:write(value and "1" or "0")
        f:close()
    end
end

--- @return boolean|nil
function M.load_termguicolors()
    local f = io.open(tgc_state_file, "r")
    if not f then
        return nil
    end
    local value = f:read("*l")
    f:close()
    if value == "1" then
        return true
    elseif value == "0" then
        return false
    end
    return nil
end

function M.toggle_termguicolors()
    local enabled = not vim.o.termguicolors
    -- reapply first so highlights recompute for the new value; some colorscheme
    -- loaders (e.g. modus-themes) force termguicolors back on as a side effect,
    -- so re-assert our choice afterwards to make sure it actually sticks
    if vim.g.colors_name then
        pcall(vim.cmd.colorscheme, vim.g.colors_name)
    end
    vim.o.termguicolors = enabled
    M.save_termguicolors(enabled)
    vim.notify("termguicolors " .. (enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
        M.save(args.match)
    end,
})

return M
