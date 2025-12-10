local M = {}

-- Cache for detected projects to avoid multiple detections
local _cached_projects = {}
local _cached_cwd = nil
local _project_root = nil

-- Project type definitions with their identifying files
local projects = {
    -- Languages with package managers
    node = { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb" },
    python = { "pyproject.toml", "setup.py", "requirements.txt", "Pipfile", "poetry.lock", "setup.cfg", "pyrightconfig.json" },
    rust = { "Cargo.toml", "Cargo.lock" },
    go = { "go.mod", "go.sum", "go.work" },
    ruby = { "Gemfile", "Gemfile.lock", ".ruby-version" },
    php = { "composer.json", "composer.lock" },
    java = { "pom.xml", "build.gradle", "build.gradle.kts", "gradlew", "settings.gradle" },
    kotlin = { "build.gradle.kts", "settings.gradle.kts" },
    dotnet = { ".csproj", ".fsproj", ".vbproj", ".sln", "global.json" },

    -- Build tools and frameworks
    cmake = { "CMakeLists.txt", "cmake" },
    make = { "Makefile", "makefile", "GNUmakefile" },
    docker = { "Dockerfile", "docker-compose.yml", "docker-compose.yaml", ".dockerignore", "compose.yaml" },
    terraform = { "main.tf", "*.tf", ".terraform" },
    ansible = { "ansible.cfg", "playbook.yml", "playbook.yaml" },

    -- Frontend frameworks
    react = { "package.json" }, -- Will need additional check for react dependency
    vue = { "vue.config.js", "vite.config.js", "nuxt.config.js", "nuxt.config.ts" },
    svelte = { "svelte.config.js", "svelte.config.ts" },
    angular = { "angular.json", ".angular-cli.json" },
    next = { "next.config.js", "next.config.mjs", "next.config.ts" },
    astro = { "astro.config.mjs", "astro.config.ts" },
    remix = { "remix.config.js", "remix.config.ts" },

    -- Mobile development
    flutter = { "pubspec.yaml", "pubspec.lock" },
    android = { "build.gradle", "AndroidManifest.xml", "gradle.properties" },
    ios = { ".xcodeproj", ".xcworkspace", "Podfile" },
    xcode = { ".xcodeproj", ".xcworkspace" },
    reactnative = { "package.json" }, -- Checked via package.json content

    -- Other
    latex = { ".tex", "main.tex", "*.tex" },
    markdown = { "README.md", "*.md" },
    jupyter = { "*.ipynb" },

    -- Monorepos
    turborepo = { "turbo.json" },
    nx = { "nx.json" },
    lerna = { "lerna.json" },
}

local ignore_dirs = {
    "node_modules",
    ".git",
    ".venv",
    "venv",
    "env",
    "__pycache__",
    "target",
    "build",
    "dist",
    ".next",
    ".nuxt",
    "vendor",
    ".turbo",
    ".cache",
    "coverage",
    "out",
}

-- Get project root (integrates with rooter)
local function get_project_root()
    if _project_root then
        return _project_root
    end

    -- Try to get from rooter if it's loaded
    local ok, rooter = pcall(require, "nvim-rooter")
    if ok and rooter.get_root then
        _project_root = rooter.get_root()
        if _project_root then
            return _project_root
        end
    end

    -- Fallback: search for common root markers
    local root_markers = { ".git", ".hg", ".svn", ".bzr" }
    local current_file = vim.fn.expand("%:p")
    local current_dir = vim.fn.expand("%:p:h")

    -- Start from current file directory
    local search_dir = current_dir
    if vim.fn.isdirectory(search_dir) == 0 then
        search_dir = vim.fn.getcwd()
    end

    -- Search upwards for root markers
    while search_dir ~= "/" do
        for _, marker in ipairs(root_markers) do
            local marker_path = search_dir .. "/" .. marker
            if vim.fn.isdirectory(marker_path) == 1 or vim.fn.filereadable(marker_path) == 1 then
                _project_root = search_dir
                return _project_root
            end
        end
        search_dir = vim.fn.fnamemodify(search_dir, ":h")
    end

    -- No root found, use cwd
    _project_root = vim.fn.getcwd()
    return _project_root
end

-- Clear cache when changing directory
vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
        _cached_projects = {}
        _cached_cwd = nil
        _project_root = nil
    end,
})

-- Check if a file matches a pattern (supports wildcards)
local function matches_pattern(filename, pattern)
    if pattern:match("%*") then
        -- Wildcard pattern matching (e.g., "*.tf")
        local pattern_regex = "^" .. pattern:gsub("%.", "%%."):gsub("%*", ".*") .. "$"
        return filename:match(pattern_regex) ~= nil
    elseif pattern:sub(1, 1) == "." then
        -- Match file extension or dotfile (e.g., ".csproj" matches "Program.csproj")
        return filename:match(vim.pesc(pattern) .. "$") ~= nil
    else
        -- Exact filename match
        return filename == pattern
    end
end

-- Read and parse package.json for framework detection
local function check_package_json(dir)
    local package_json_path = dir .. "/package.json"
    if vim.fn.filereadable(package_json_path) ~= 1 then
        return {}
    end

    local detected = {}
    local ok, content = pcall(vim.fn.readfile, package_json_path)
    if not ok then
        return detected
    end

    local json_str = table.concat(content, "\n")

    -- Check for frameworks in dependencies
    local checks = {
        { pattern = '"react"',         type = "react" },
        { pattern = '"next"',          type = "next" },
        { pattern = '"vue"',           type = "vue" },
        { pattern = '"@angular/core"', type = "angular" },
        { pattern = '"svelte"',        type = "svelte" },
        { pattern = '"astro"',         type = "astro" },
        { pattern = '"remix"',         type = "remix" },
        { pattern = '"react%-native"', type = "reactnative" },
        { pattern = '"turbo"',         type = "turborepo" },
        { pattern = '"@nx/',           type = "nx" },
        { pattern = '"lerna"',         type = "lerna" },
    }

    for _, check in ipairs(checks) do
        if json_str:match(check.pattern) then
            table.insert(detected, check.type)
        end
    end

    return detected
end

-- Get project type for a specific directory
function M.get_project_type(dir)
    local scandir = vim.loop.fs_scandir(dir)
    if not scandir then return nil end

    local files = {}
    local directories = {}
    local project_types = {}

    -- Get all files and directories in the dir
    while true do
        local name, type = vim.loop.fs_scandir_next(scandir)
        if not name then break end
        if type == "file" then
            table.insert(files, name)
        elseif type == "directory" then
            table.insert(directories, name)
        end
    end

    -- Check all files to see if they match any projects
    for project_type, patterns in pairs(projects) do
        for _, pattern in ipairs(patterns) do
            -- Check against files
            for _, file in ipairs(files) do
                if matches_pattern(file, pattern) then
                    if not vim.tbl_contains(project_types, project_type) then
                        table.insert(project_types, project_type)
                    end
                end
            end

            -- Check against directories for patterns like ".xcodeproj"
            if pattern:sub(1, 1) == "." then
                for _, directory in ipairs(directories) do
                    if matches_pattern(directory, pattern) then
                        if not vim.tbl_contains(project_types, project_type) then
                            table.insert(project_types, project_type)
                        end
                    end
                end
            end
        end
    end

    -- Additional framework detection for Node.js projects
    if vim.tbl_contains(project_types, "node") then
        local frameworks = check_package_json(dir)
        for _, framework in ipairs(frameworks) do
            if not vim.tbl_contains(project_types, framework) then
                table.insert(project_types, framework)
            end
        end
    end

    -- Return project types
    if #project_types > 0 then
        return project_types
    else
        return nil
    end
end

-- Detect projects starting from project root
function M.detect_projects()
    local root = get_project_root()

    -- Return cached result if root hasn't changed
    if _cached_cwd == root and _cached_projects and #_cached_projects > 0 then
        return _cached_projects
    end

    -- Update cache
    _cached_cwd = root
    _cached_projects = {}

    -- Check project root directory
    local project_types = M.get_project_type(root)
    if project_types and #project_types > 0 then
        _cached_projects = project_types

        -- Only notify on first detection or when types change
        local project_list = table.concat(project_types, ", ")
        vim.schedule(function()
            vim.notify("Project types: " .. project_list, vim.log.levels.INFO, {
                title = "Project Detection",
                timeout = 2000,
            })
        end)

        return project_types
    end

    -- If no projects found in root, scan immediate subdirectories (max 1 level)
    -- This helps with monorepos
    local scandir = vim.loop.fs_scandir(root)
    if not scandir then return {} end

    while true do
        local name, type = vim.loop.fs_scandir_next(scandir)
        if not name then break end

        if type == "directory" then
            -- Check if the directory should be ignored
            local should_ignore = false
            for _, ignored in ipairs(ignore_dirs) do
                if name == ignored then
                    should_ignore = true
                    break
                end
            end

            if not should_ignore then
                local subdir = root .. "/" .. name
                local sub_project_types = M.get_project_type(subdir)
                if sub_project_types and #sub_project_types > 0 then
                    -- Merge unique project types
                    for _, ptype in ipairs(sub_project_types) do
                        if not vim.tbl_contains(_cached_projects, ptype) then
                            table.insert(_cached_projects, ptype)
                        end
                    end
                end
            end
        end
    end

    if #_cached_projects > 0 then
        local project_list = table.concat(_cached_projects, ", ")
        vim.schedule(function()
            vim.notify("Monorepo detected: " .. project_list, vim.log.levels.INFO, {
                title = "Project Detection",
                timeout = 2000,
            })
        end)
    end

    return _cached_projects
end

-- Check if a specific project type exists
function M.check_project_condition(project)
    local project_types = M.detect_projects()
    if not project_types then
        return false
    end

    for _, project_type in ipairs(project_types) do
        if project_type == project then
            return true
        end
    end
    return false
end

-- Check if any of the given project types exist
function M.check_any_project(...)
    local projects_to_check = { ... }
    local project_types = M.detect_projects()

    if not project_types then
        return false
    end

    for _, check_project in ipairs(projects_to_check) do
        for _, project_type in ipairs(project_types) do
            if project_type == check_project then
                return true
            end
        end
    end
    return false
end

-- Get the project root directory
function M.get_root()
    return get_project_root()
end

-- Force re-detection of projects
function M.force_detect()
    _cached_projects = {}
    _cached_cwd = nil
    _project_root = nil
    return M.detect_projects()
end

-- Get all detected project types
function M.get_all_types()
    return M.detect_projects() or {}
end

return M
