local function python_path()
    local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
    if venv then
        return venv .. "/bin/python"
    end
    return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

return {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = python_path,
        console = "integratedTerminal",
    },
    {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
            return vim.split(vim.fn.input("Arguments: "), " ", { trimempty = true })
        end,
        pythonPath = python_path,
        console = "integratedTerminal",
    },
}
