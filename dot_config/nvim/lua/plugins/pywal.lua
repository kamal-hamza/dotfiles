return {
    "uZer/pywal16.nvim",
    as = "pywal16",
    lazy = false, -- We want this to be available at startup
    config = function()
        -- Create a user command that can be called externally to reload the theme
        vim.api.nvim_create_user_command("ReloadPywal", function()
            -- Clear the require cache for the pywal plugin to ensure it re-reads the colors
            package.loaded["pywal16"] = nil
            package.loaded["pywal16.core"] = nil
            -- Re-apply the colorscheme
            vim.cmd("colorscheme pywal16")
            vim.notify("Pywal theme reloaded!", vim.log.levels.INFO)
        end, {})
    end,
}
