
set -U DOTFILES_PATH "$HOME/.dotfiles"

# load the _path.fish files first
for file in $DOTFILES_PATH/**/_path.fish
  source $file
end

if status is-interactive
  # load other files later
  set files_to_load (find $DOTFILES_PATH -name '*.fish' | grep -v fish/config.fish | grep -v _path.fish)
  for file in $files_to_load
    source $file
  end

  source $DOTFILES_PATH/fish/themes/tokyonight_night.fish.theme
  # theme_gruvbox dark || echo "Fisher not installed: theme_gruvbox not found"

  # remove greeting
  set fish_greeting
end
alias claude="/home/jumski/.claude/local/claude"
