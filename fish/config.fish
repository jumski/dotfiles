
set -U DOTFILES_PATH "$HOME/.dotfiles"

# Add all module function directories to fish_function_path for autoloading
for func_dir in $DOTFILES_PATH/*/functions
  if test -d $func_dir
    set -p fish_function_path $func_dir
  end
end

# load the _path.fish files first
for file in $DOTFILES_PATH/**/_path.fish
  source $file
end

if status is-interactive
  # load other files later (excluding functions/ dirs since they're autoloaded)
  set files_to_load (find $DOTFILES_PATH -name '*.fish' | grep -v fish/config.fish | grep -v _path.fish | grep -v '.test.fish' | grep -v '/functions/' | grep -v '/tests/')
  for file in $files_to_load
    source $file
  end

  source $DOTFILES_PATH/fish/themes/tokyonight_night.fish.theme
  # theme_gruvbox dark || echo "Fisher not installed: theme_gruvbox not found"

  # remove greeting
  set fish_greeting
end
alias claude="/home/jumski/.claude/local/claude"
