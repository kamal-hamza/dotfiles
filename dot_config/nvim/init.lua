require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("utils.todo").setup({
    target_file = "todo.md",
    global_file = "~/todo.md"
})


-- theme overrides
require("utils.color_overrides").setup_colorscheme_overrides()

-- ===================================================================
-- Pywal Colorscheme with Fallback Logic
-- ===================================================================

-- Function to check if a file exists
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Path to the pywal-generated colorscheme file
local pywal_colors = os.getenv("HOME") .. "/.cache/wal/colors-wal.vim"

-- Check if the pywal theme exists and apply it, otherwise use the fallback
if file_exists(pywal_colors) then
    vim.cmd("colorscheme pywal16")
else
    -- If not found, fall back to your default theme
    vim.cmd("colorscheme base16-black-metal-gorgoroth")
end
-- ===================================================================

vim.lsp.enable {
    "lua_ls",
    "ts_ls",
    "css_ls",
    "clangd",
    "omnisharp",
    "tailwindcss"
}
