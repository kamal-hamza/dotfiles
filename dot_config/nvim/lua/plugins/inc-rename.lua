return {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
        {
            "<leader>rn",
            function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end,
            expr = true,
            desc = "LSP: Incremental Rename",
        },
    },
    config = function()
        require("inc_rename").setup({
            cmd_name = "IncRename",
            hl_group = "Substitute",
            preview_empty_name = false,
            show_message = true,
            input_buffer_type = nil,
            post_hook = nil,
        })
    end,
}
