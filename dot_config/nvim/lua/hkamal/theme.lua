local M = {}

local state_file = vim.fn.stdpath("state") .. "/theme.txt"

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

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
        M.save(args.match)
    end,
})

return M
