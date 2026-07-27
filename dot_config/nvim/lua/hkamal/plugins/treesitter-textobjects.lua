vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" })

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = true,
        selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
        },
    },
    move = {
        set_jumps = true,
    },
})

local select = require("nvim-treesitter-textobjects.select")

local select_keymaps = {
    ["af"] = "@function.outer",
    ["if"] = "@function.inner",
    ["ac"] = "@class.outer",
    ["ic"] = "@class.inner",
    ["aa"] = "@parameter.outer",
    ["ia"] = "@parameter.inner",
    ["al"] = "@loop.outer",
    ["il"] = "@loop.inner",
}

for key, capture in pairs(select_keymaps) do
    vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(capture, "textobjects")
    end, { desc = "Select " .. capture })
end

local move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "n", "x", "o" }, "]m", function()
    move.goto_next_start("@function.outer", "textobjects")
end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "]]", function()
    move.goto_next_start("@class.outer", "textobjects")
end, { desc = "Next class start" })
vim.keymap.set({ "n", "x", "o" }, "]M", function()
    move.goto_next_end("@function.outer", "textobjects")
end, { desc = "Next function end" })
vim.keymap.set({ "n", "x", "o" }, "][", function()
    move.goto_next_end("@class.outer", "textobjects")
end, { desc = "Next class end" })
vim.keymap.set({ "n", "x", "o" }, "[m", function()
    move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "Previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[[", function()
    move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "Previous class start" })
vim.keymap.set({ "n", "x", "o" }, "[M", function()
    move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "Previous function end" })
vim.keymap.set({ "n", "x", "o" }, "[]", function()
    move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "Previous class end" })
