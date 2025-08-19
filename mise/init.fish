# mise initialization for fish shell
# This file integrates mise with fish shell without affecting asdf

# Add mise to PATH if not already present
if not contains $HOME/.local/share/mise/bin $PATH
    set -gx PATH $HOME/.local/share/mise/bin $PATH
end

# Load mise completions if available
if test -f $HOME/.local/share/mise/completions/mise.fish
    source $HOME/.local/share/mise/completions/mise.fish
end

# Note: We're not activating mise automatically to avoid conflicts with asdf
# To use mise, manually run: mise activate fish | source
