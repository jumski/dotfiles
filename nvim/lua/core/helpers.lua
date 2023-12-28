local util = require('lspconfig/util')

local M = {}

-- Just looks for common project top-level files or directories to find a "project root"
function M.find_project_root()
  local patterns = {
    '.git',
    '.editorconfig',
    '.env',
    '.envrc',
    'Makefile',
    'Rakefile',
    'README.md',
    '.vscode',
    -- 'package.json',
    -- 'Gemfile',
    -- 'pyproject.toml',
    -- 'poetry.lock',
    -- 'requirements.txt'
  }

  return util.find_git_ancestor(vim.fn.getcwd()) or util.root_pattern(unpack(patterns))(vim.fn.getcwd())
end

-- Return fixed python runtime for now
-- TODO: use just 'python -iq' and leverage direnv to overwrite what 'python' means
function M.project_python_runtime()
  if M.has_poetry() then
    return { "poetry", "run", "python", "-iq" }
  end

  return { "python",  "-iq" }
end

function M.has_poetry()
  local project_root = M.find_project_root()

  local files = {
    'poetry.lock',
    'pyproject.toml',
    'poetry.toml'
  }

  for _, file in ipairs(files) do
    if vim.fn.filereadable(project_root .. "/" .. file) == 1 then
      return true
    end
  end

  return false
end

return M
