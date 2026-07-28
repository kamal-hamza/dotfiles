local function cargo_binary_name()
    local cargo_toml = vim.fn.getcwd() .. "/Cargo.toml"
    if vim.fn.filereadable(cargo_toml) == 0 then
        return nil
    end
    for _, line in ipairs(vim.fn.readfile(cargo_toml)) do
        local name = line:match('^name%s*=%s*"(.-)"')
        if name then
            return name
        end
    end
    return nil
end

return {
    {
        name = "Debug (cargo build)",
        type = "codelldb",
        request = "launch",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        program = function()
            vim.fn.system("cargo build")
            if vim.v.shell_error ~= 0 then
                error("cargo build failed")
            end
            local name = cargo_binary_name()
            if name then
                return vim.fn.getcwd() .. "/target/debug/" .. name
            end
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
    },
    {
        name = "Launch (manual path)",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
