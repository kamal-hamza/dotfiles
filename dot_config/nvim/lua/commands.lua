-- global term command
vim.api.nvim_create_user_command("Term", function()
    vim.cmd('vsplit | term')
    vim.cmd('startinsert')
end, {})

-- vsplit terminal
vim.api.nvim_create_user_command('Vsterm', function()
    vim.cmd('vsplit | term')
end, {})

-- split terminal
vim.api.nvim_create_user_command('Sterm', function()
    vim.cmd('split | term')
end, {})

-- fix common shift-key typos
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Wa', 'wa', {})
vim.api.nvim_create_user_command('QA', 'qa', {})
