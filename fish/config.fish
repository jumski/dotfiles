
#source aliases.fish

set -U DOTFILES_PATH "$HOME/.dotfiles"

# load the _path.fish files first
for file in $DOTFILES_PATH/**/_path.fish
  source $file
end

# load other files later
set files_to_load (find -name '*.fish' | grep -v fish/config.fish | grep -v _path.fish)
for file in $files_to_load
  source $file
end
