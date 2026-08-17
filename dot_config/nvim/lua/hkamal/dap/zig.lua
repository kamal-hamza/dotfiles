local function zig_out_binary()
    local entries = vim.fn.glob(vim.fn.getcwd() .. "/zig-out/bin/*", false, true)
    if #entries == 1 then
        return entries[1]
    end
    return nil
end

return {
    {
        name = "Debug (zig build)",
        type = "codelldb",
        request = "launch",
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        program = function()
            vim.fn.system("zig build")
            if vim.v.shell_error ~= 0 then
                error("zig build failed")
            end
            local bin = zig_out_binary()
            if bin then
                return bin
            end
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
        end,
    },
    {
        name = "Launch (manual path)",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}
