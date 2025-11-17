#!/usr/bin/env fish
# Link wt config to dotfiles for version control

function wt_config_link -d "Link wt config to dotfiles"
    # Load common utilities
    source ~/.dotfiles/wt/lib/common.fish

    # Get repo root
    set -l repo_root (_wt_get_repo_root)
    if test -z "$repo_root"
        echo "Error: Not in a wt repository" >&2
        return 1
    end

    set -l repo_name (basename $repo_root)
    set -l dotfiles_path "$HOME/.dotfiles/wt/repos/$repo_name"

    # Already linked?
    if test -L "$repo_root/.wt"
        _wt_success "Already linked to dotfiles"
        set -l target (readlink "$repo_root/.wt")
        echo "  Target: $target"
        return 0
    end

    # Config already in new format?
    if test -d "$repo_root/.wt"
        echo "Error: .wt directory already exists but is not a symlink" >&2
        return 1
    end

    # Nothing to migrate?
    if not test -f "$repo_root/.wt-config"
        echo "Error: No .wt-config found to migrate" >&2
        echo "  Are you in the repository root?" >&2
        return 1
    end

    # Verify dotfiles wt directory exists
    if not test -d "$HOME/.dotfiles/wt"
        echo "Error: ~/.dotfiles/wt does not exist" >&2
        return 1
    end

    # Show what will happen
    _wt_action "Moving config to dotfiles..."
    echo "  From: $repo_root/.wt-config"
    echo "  To:   $dotfiles_path/"

    # Create dotfiles directory
    mkdir -p "$dotfiles_path"
    or begin
        echo "Error: Failed to create $dotfiles_path" >&2
        return 1
    end

    # Move config file
    mv "$repo_root/.wt-config" "$dotfiles_path/config"
    or begin
        echo "Error: Failed to move .wt-config" >&2
        return 1
    end

    # Move post-create hook if it exists
    if test -f "$repo_root/.wt-post-create"
        mv "$repo_root/.wt-post-create" "$dotfiles_path/post-create"
        or begin
            echo "Error: Failed to move .wt-post-create" >&2
            # Try to restore config
            mv "$dotfiles_path/config" "$repo_root/.wt-config"
            return 1
        end
    end

    # Create symlink
    ln -s "$dotfiles_path" "$repo_root/.wt"
    or begin
        echo "Error: Failed to create symlink" >&2
        # Try to restore files
        mv "$dotfiles_path/config" "$repo_root/.wt-config"
        test -f "$dotfiles_path/post-create" && mv "$dotfiles_path/post-create" "$repo_root/.wt-post-create"
        return 1
    end

    _wt_success "Config linked to dotfiles"
    echo "  Location: $dotfiles_path"
    echo ""
    echo "  Next steps:"
    echo "  • Commit to dotfiles: cd ~/.dotfiles && git add wt/repos/$repo_name"
    echo "  • On other machines: Run 'wt_config_link' in repo root to create symlink"
end
