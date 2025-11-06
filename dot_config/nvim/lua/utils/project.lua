local M = {}

-- Cache for detected projects to avoid multiple detections
local _cached_projects = nil
local _cached_cwd = nil

-- Project type definitions with their identifying files
local projects = {
  -- Languages with package managers
  node = { "package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml" },
  python = { "pyproject.toml", "setup.py", "requirements.txt", "Pipfile", "poetry.lock", "setup.cfg" },
  rust = { "Cargo.toml", "Cargo.lock" },
  go = { "go.mod", "go.sum" },
  ruby = { "Gemfile", "Gemfile.lock", ".ruby-version" },
  php = { "composer.json", "composer.lock" },
  java = { "pom.xml", "build.gradle", "build.gradle.kts", "gradlew" },
  dotnet = { ".csproj", ".fsproj", ".vbproj", ".sln" },
  
  -- Build tools and frameworks
  cmake = { "CMakeLists.txt", "cmake" },
  make = { "Makefile", "makefile" },
  docker = { "Dockerfile", "docker-compose.yml", "docker-compose.yaml", ".dockerignore" },
  terraform = { "main.tf", "*.tf" },
  ansible = { "ansible.cfg", "playbook.yml", "playbook.yaml" },
  
  -- Frontend frameworks
  react = { "package.json" }, -- Will need additional check for react dependency
  vue = { "vue.config.js", "vite.config.js" },
  svelte = { "svelte.config.js" },
  angular = { "angular.json" },
  next = { "next.config.js", "next.config.mjs" },
  
  -- Mobile development
  flutter = { "pubspec.yaml", "pubspec.lock" },
  android = { "build.gradle", "AndroidManifest.xml" },
  ios = { ".xcodeproj", ".xcworkspace", "Podfile" },
  xcode = { ".xcodeproj", ".xcworkspace" },
  
  -- Other
  latex = { ".tex", "main.tex" },
  markdown = { "README.md", ".md" },
  jupyter = { ".ipynb" },
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
}

-- find project files in cwd and child dirs
function M.detect_projects()
  local cwd = vim.fn.getcwd()
  
  -- Return cached result if cwd hasn't changed
  if _cached_cwd == cwd and _cached_projects then
    return _cached_projects
  end
  
  -- Update cache
  _cached_cwd = cwd
  _cached_projects = nil

  -- Check current working directory
  local project_files = M.get_project_type(cwd)
  if project_files ~= nil then
    _cached_projects = project_files
    -- Send single notification with all detected projects
    local project_list = table.concat(project_files, ", ")
    vim.schedule(function()
      vim.notify("Projects detected: " .. project_list, vim.log.levels.INFO, { title = "Project Detection" })
    end)
    return project_files
  end

  -- Look for project files in child directories (up to 2 levels deep)
  local function scan_directory(dir, depth)
    if depth > 2 then return nil end
    
    local scandir = vim.loop.fs_scandir(dir)
    if not scandir then return nil end
    
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
          local subdir = dir .. "/" .. name
          local project_files = M.get_project_type(subdir)
          if project_files ~= nil then
            _cached_projects = project_files
            -- Send single notification with all detected projects
            local project_list = table.concat(project_files, ", ")
            vim.schedule(function()
              vim.notify("Projects detected in " .. name .. "/: " .. project_list, vim.log.levels.INFO, { title = "Project Detection" })
            end)
            return project_files
          end
          
          -- Recursively scan subdirectories
          local nested_result = scan_directory(subdir, depth + 1)
          if nested_result then
            return nested_result
          end
        end
      end
    end
    return nil
  end
  
  local result = scan_directory(cwd, 0)
  _cached_projects = result
  return result
end

function M.get_project_type(dir --[[string]])
  local scandir = vim.loop.fs_scandir(dir)
  if not scandir then return nil end
  
  local files = {}
  local directories = {}
  local project_types = {}
  
  -- get all files and directories in the dir
  while true do
    local name, type = vim.loop.fs_scandir_next(scandir)
    if not name then break end
    if type == "file" then
      table.insert(files, name)
    elseif type == "directory" then
      table.insert(directories, name)
    end
  end
  
  -- check all files to see if they match any projects
  for project_type, patterns in pairs(projects) do
    for _, pattern in ipairs(patterns) do
      -- Check against files
      for _, file in ipairs(files) do
        local matched = false
        
        if pattern:match("%*") then
          -- Wildcard pattern matching (e.g., "*.tf")
          local pattern_regex = "^" .. pattern:gsub("%.", "%%."):gsub("%*", ".*") .. "$"
          if file:match(pattern_regex) then
            matched = true
          end
        elseif pattern:sub(1, 1) == "." then
          -- Match file extension (e.g., ".csproj" matches "Program.csproj")
          if file:match(vim.pesc(pattern) .. "$") then
            matched = true
          end
        else
          -- Exact filename match
          if file == pattern then
            matched = true
          end
        end
        
        if matched and not vim.tbl_contains(project_types, project_type) then
          table.insert(project_types, project_type)
        end
      end
      
      -- Check against directories for patterns like ".xcodeproj"
      if pattern:sub(1, 1) == "." then
        for _, directory in ipairs(directories) do
          if directory:match(vim.pesc(pattern) .. "$") then
            if not vim.tbl_contains(project_types, project_type) then
              table.insert(project_types, project_type)
            end
          end
        end
      end
    end
  end
  
  -- Additional checks for framework detection
  if vim.tbl_contains(project_types, "node") then
    -- Check if it's a React, Vue, Angular, Next.js project
    local package_json_path = dir .. "/package.json"
    if vim.fn.filereadable(package_json_path) == 1 then
      local package_json = vim.fn.readfile(package_json_path)
      local content = table.concat(package_json, "\n")
      
      if content:match('"react"') or content:match('"@types/react"') then
        if not vim.tbl_contains(project_types, "react") then
          table.insert(project_types, "react")
        end
      end
      
      if content:match('"next"') then
        if not vim.tbl_contains(project_types, "next") then
          table.insert(project_types, "next")
        end
      end
      
      if content:match('"vue"') then
        if not vim.tbl_contains(project_types, "vue") then
          table.insert(project_types, "vue")
        end
      end
      
      if content:match('"@angular/core"') then
        if not vim.tbl_contains(project_types, "angular") then
          table.insert(project_types, "angular")
        end
      end
      
      if content:match('"svelte"') then
        if not vim.tbl_contains(project_types, "svelte") then
          table.insert(project_types, "svelte")
        end
      end
    end
  end
  
  -- return project types
  if #project_types > 0 then
    return project_types
  else
    return nil
  end
end

function M.check_project_condition(project)
  local project_types = M.detect_projects() or {}
  for _, project_type in ipairs(project_types) do
    if project_type == project then
      return true
    end
  end
  return false
end

return M
