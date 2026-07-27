vim.pack.add({
    "https://github.com/b0o/incline.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

local devicons = require("nvim-web-devicons")

require("incline").setup({
    render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
            filename = "[No Name]"
        end
        local icon, color = devicons.get_icon_color(filename)
        return {
            icon and { icon .. " ", guifg = color } or "",
            filename,
        }
    end,
})
