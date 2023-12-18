local util = require('lspconfig/util')

return {

  -- Define a function to find the project root based on certain patterns
  find_project_root = function()
    -- List of patterns to detect the root directory
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

    -- Use the 'util.find_git_ancestor' function or similar to detect the root
    local root = util.find_git_ancestor(vim.fn.getcwd()) or util.root_pattern(unpack(patterns))(vim.fn.getcwd())

    return root
  end
}
