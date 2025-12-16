#!/usr/bin/env fish
# Link wt config to dotfiles for version control

function wt_config_link -d "Link wt config to dotfiles"
    # Load common utilities
    source ~/.dotfiles/wt/lib/common.fish

    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt config-link

Migrate wt configuration to dotfiles for version control.

This command:
  • Moves .wt-config → ~/.dotfiles/wt/repos/REPO/config
  • Moves .wt-post-create → ~/.dotfiles/wt/repos/REPO/post-create
  • Creates symlink: .wt → ~/.dotfiles/wt/repos/REPO/

Benefits:
  • Config is version controlled via dotfiles
  • Automatically synced across machines
  • Run once per repository

Requirements:
  • Must be in repository root
  • Must have .wt-config file (legacy format)
  • ~/.dotfiles/wt directory must exist

After migration:
  • Commit to dotfiles: cd ~/.dotfiles && git add wt/repos/
  • On other machines: Run 'wt config-link' to create symlink"
    and return 0

    # Get repo root - try wt repo first, fall back to git repo or .bare directory
    set -l repo_root (_wt_get_repo_root)
    if test -z "$repo_root"
        # Not a wt repo (no .wt or .wt-config), check other indicators
        if test -d ".bare"
            # This is a wt repo root (has .bare directory)
            set repo_root (pwd)
        else if git rev-parse --git-dir >/dev/null 2>&1
            # This is a regular git repo or worktree
            set repo_root (git rev-parse --show-toplevel)
        else
            echo "Error: Not in a git or wt repository" >&2
            return 1
        end
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

    # Check if there's anything to do
    set -l has_local_config (test -f "$repo_root/.wt-config"; and echo yes; or echo no)
    set -l has_dotfiles_config (test -f "$dotfiles_path/config"; and echo yes; or echo no)

    if test "$has_local_config" = "no" -a "$has_dotfiles_config" = "no"
        echo "Error: No .wt-config found to link" >&2
        echo "  Are you in the repository root?" >&2
        return 1
    end

    # Verify dotfiles wt directory exists
    if not test -d "$HOME/.dotfiles/wt"
        echo "Error: ~/.dotfiles/wt does not exist" >&2
        return 1
    end

    # Handle case where config exists in both places
    if test "$has_local_config" = "yes" -a "$has_dotfiles_config" = "yes"
        echo "⚠️  Config already exists in dotfiles" >&2
        echo ""
        echo "  Dotfiles: $dotfiles_path/config" >&2
        echo "  Local:    $repo_root/.wt-config" >&2
        echo ""
        echo "  Differences:" >&2
        echo "  ────────────" >&2

        # Show diff (exit code 0 if identical, 1 if different)
        if diff -u "$dotfiles_path/config" "$repo_root/.wt-config"
            echo "  (Files are identical)" >&2
        end

        echo "" >&2
        echo "  Options:" >&2
        echo "  1. Remove local config and re-run to create symlink:" >&2
        echo "     rm .wt-config && wt config-link" >&2
        echo "" >&2
        echo "  2. Manually merge changes, then remove local config:" >&2
        echo "     # Edit $dotfiles_path/config" >&2
        echo "     rm .wt-config && wt config-link" >&2
        return 1
    end

    # Handle case where only dotfiles config exists - just link it
    if test "$has_local_config" = "no" -a "$has_dotfiles_config" = "yes"
        _wt_action "Linking existing dotfiles config..."
        echo "  From: $dotfiles_path"

        # Ensure pre-remove hook exists
        _wt_ensure_pre_remove_hook "$dotfiles_path"

        # Create symlink
        ln -s "$dotfiles_path" "$repo_root/.wt"
        or begin
            echo "Error: Failed to create symlink" >&2
            return 1
        end

        _wt_success "Config linked to dotfiles"
        echo "  Location: $dotfiles_path"
        return 0
    end

    # Handle case where only local config exists - migrate it
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

    # Create pre-remove hook template (new feature, won't exist in legacy repos)
    _wt_ensure_pre_remove_hook "$dotfiles_path"

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
