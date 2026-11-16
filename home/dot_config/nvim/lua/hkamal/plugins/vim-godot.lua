vim.pack.add({ "https://github.com/habamax/vim-godot" })

-- lets the Godot editor use this Neovim instance as its external script
-- editor (Editor Settings > General > External > Exec Path/Flags:
-- nvim --server ./godothost --remote-send ...)
local gdproject = io.open(vim.fn.getcwd() .. "/project.godot", "r")
if gdproject then
    io.close(gdproject)
    vim.fn.serverstart("./godothost")
end
