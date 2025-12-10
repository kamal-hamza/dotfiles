return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
    },
    config = function()
        require("toggleterm").setup({
            -- Size can be a number or function which is passed the current terminal
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            -- Open in insert mode
            open_mapping = [[<leader>tt]],
            -- Hide the number column in terminal
            hide_numbers = true,
            -- Show line numbers in terminal (false by default)
            shade_filetypes = {},
            autochdir = false,
            shade_terminals = true,
            shading_factor = 2,
            -- Start terminal in insert mode
            start_in_insert = true,
            insert_mappings = true,
            terminal_mappings = true,
            -- Persist size of terminal across toggles
            persist_size = true,
            persist_mode = true,
            -- Direction of the terminal (horizontal bottom like vscode)
            direction = "horizontal",
            -- Close the terminal window when the process exits
            close_on_exit = true,
            -- Shell to use
            shell = vim.o.shell,
            -- Auto scroll to the bottom on terminal output
            auto_scroll = true,
            -- Floating terminal options
            float_opts = {
                border = "curved",
                winblend = 0,
            },
            -- Window options for terminal
            winbar = {
                enabled = false,
                name_formatter = function(term)
                    return term.name
                end
            },
        })

        -- Keybinding to close terminal with Esc when in terminal mode
        function _G.set_terminal_keymaps()
            local opts = { buffer = 0 }
            vim.keymap.set('t', '<esc>', [[<C-\><C-n><cmd>close<cr>]], opts)
            vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
        end

        -- Automatically set terminal keymaps when opening a terminal
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end
}
