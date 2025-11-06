require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("utils.todo").setup({
    target_file = "todo.md",
    global_file = "~/todo.md"
})


-- theme overrides - auto-detect theme
local theme_state_file = vim.fn.stdpath("config") .. "/.theme-mode"
local theme = "dark" -- default
if vim.fn.filereadable(theme_state_file) == 1 then
    local f = io.open(theme_state_file, "r")
    if f then
        theme = f:read("*line") or "dark"
        f:close()
    end
end

-- Load the appropriate theme
if theme == "light" then
    require("plugins.themes.soft-focus-light").setup()
else
    require("plugins.themes.soft-focus-dark").setup()
end
