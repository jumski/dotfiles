
set -U DOTFILES_PATH "$HOME/.dotfiles"

# load the _path.fish files first
for file in $DOTFILES_PATH/**/_path.fish
  source $file
end

# load other files later
set files_to_load (find $DOTFILES_PATH -name '*.fish' | grep -v fish/config.fish | grep -v _path.fish)
for file in $files_to_load
  source $file
end

theme_gruvbox dark

# remove greeting
set fish_greeting