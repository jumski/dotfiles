# Add Bob's Neovim binary directory to PATH
# Bob installs Neovim versions to ~/.local/share/bob/
# and creates a proxy binary in nvim-bin that points to the active version
fish_add_path --prepend $HOME/.local/share/bob/nvim-bin
