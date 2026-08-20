local bashdb_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "bash-debug-adapter", "extension", "bashdb_dir")

return {
    {
        type = "bashdb",
        request = "launch",
        name = "Launch file",
        showDebugOutput = true,
        pathBashdb = vim.fs.joinpath(bashdb_dir, "bashdb"),
        pathBashdbLib = bashdb_dir,
        trace = true,
        file = "${file}",
        program = "${file}",
        cwd = "${workspaceFolder}",
        pathCat = "cat",
        pathBash = "/bin/bash",
        pathMkfifo = "mkfifo",
        pathPkill = "pkill",
        args = {},
        argsString = "",
        env = {},
        terminalKind = "integrated",
    },
}
