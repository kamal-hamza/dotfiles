local M = {}

local projects = {
  dotnet = { ".csproj" },
  node = { "package.json" },
  xcode = { ".xcodeproj" }
}

local ignore_dirs = {
  "node_modules",
  ".git",
}

-- find project files in cwd and child dirs
function M.detect_projects()
  local cwd = vim.fn.getcwd()

  -- Check current working directory
  local project_files = M.get_project_type(cwd)
  if project_files ~= nil then
    for _, project_file in ipairs(project_files) do
      vim.notify("Project Detected, Project: " .. project_file, vim.log.levels.INFO)
    end
    return project_files
  end

  -- Look for project files in child directories
  local scandir = vim.loop.fs_scandir(cwd)
  while scandir do
    local name, type = vim.loop.fs_scandir_next(scandir)
    if not name or not type then break end

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
        local dir = cwd .. "/" .. name
        project_files = M.get_project_type(dir)
        if project_files ~= nil then
          for _, project_file in ipairs(project_files) do
            vim.notify("Project Detected, Project: " .. project_file, vim.log.levels.INFO)
          end
          return project_files
        end
      end
    end
  end
  -- vim.notify("No Project Found!", vim.log.levels.INFO)
  return nil
end

function M.get_project_type(dir --[[string]])
  local scandir = vim.loop.fs_scandir(dir)
  local files = {}
  local project_types = {}
  -- get all files in the dir
  while scandir do
    local name, type = vim.loop.fs_scandir_next(scandir)
    if not name then break end
    if not type then break end
    if type == "file" then
      table.insert(files, name)
    end
  end
  -- check all files to see if they match any projects
  for project_type, patterns in pairs(projects) do
    for _, pattern in ipairs(patterns) do
      for _, file in ipairs(files) do
        if pattern:sub(1, 1) == "." then
          -- Match file extension (e.g., ".csproj" matches "Program.csproj")
          if file:match(vim.pesc(pattern) .. "$") then
            table.insert(project_types, project_type)
          end
        else
          -- Exact filename match
          if file == pattern then
            table.insert(project_types, project_type)
          end
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
