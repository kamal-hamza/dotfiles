-- neovim has no builtin detection for docker-compose files, but
-- docker_compose_language_service (see lsp/docker_compose_language_service.lua)
-- only attaches to the "yaml.docker-compose" compound filetype
vim.filetype.add({
    filename = {
        ["docker-compose.yml"] = "yaml.docker-compose",
        ["docker-compose.yaml"] = "yaml.docker-compose",
        ["compose.yml"] = "yaml.docker-compose",
        ["compose.yaml"] = "yaml.docker-compose",
    },
    pattern = {
        [".*/docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
        [".*/compose%..*%.ya?ml"] = "yaml.docker-compose",
    },
})
