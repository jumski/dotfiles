function __mksupa_check_repo -d "Check if supatemp directory is a git repo"
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"

    # Check if directory doesn't exist
    if not test -d "$base_dir"
        return 1  # Directory doesn't exist
    end

    # Check if it's a git repo
    if not test -d "$base_dir/.git"
        return 2  # Directory exists but is not a git repo
    end

    return 0  # All good, it's a git repo
end

function __mksupa_offer_clone -d "Offer to clone the supatemp repository"
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"
    set -l clone_cmd "gh repo clone pgflow-dev/supatemp $base_dir"

    echo ""
    set_color yellow
    echo "⚠ Supatemp directory doesn't exist yet"
    set_color normal
    echo ""
    set_color cyan
    echo "Would you like to clone the repository?"
    set_color normal
    set_color brblack
    echo "  → $clone_cmd"
    set_color normal
    echo ""
    read -l -P "Clone repository? [y/N] " response

    if test "$response" = "y" -o "$response" = "Y"
        echo ""
        set_color blue
        echo "📦 Cloning repository..."
        set_color normal
        eval $clone_cmd
        if test $status -eq 0
            echo ""
            set_color green
            echo "✓ Repository cloned successfully"
            set_color normal
            return 0
        else
            echo ""
            set_color red
            echo "✗ Failed to clone repository"
            set_color normal
            set_color brblack
            echo "  → $clone_cmd"
            set_color normal
            return 1
        end
    else
        echo ""
        set_color yellow
        echo "Cancelled. To proceed, please run:"
        set_color normal
        set_color brblack
        echo "  → $clone_cmd"
        set_color normal
        return 1
    end
end

function __mksupa_git_commit_push -d "Commit and push the new temp directory"
    set -l dir_name $argv[1]
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"

    echo ""
    set_color magenta
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📝 Git: Committing changes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal

    # Stage all files (using -C to run in different directory without changing cwd)
    set_color brblack
    echo "  → git add ."
    set_color normal
    git -C "$base_dir" add .
    if test $status -ne 0
        set_color red
        echo "  ✗ git add failed"
        set_color normal
        set_color brblack
        echo "    Please commit and push manually from: $base_dir"
        set_color normal
        return 1
    end

    # Commit with message
    set -l commit_msg "Add temp project: $dir_name"
    set_color brblack
    echo "  → git commit -m \"$commit_msg\""
    set_color normal
    git -C "$base_dir" commit -m "$commit_msg"
    set -l commit_status $status
    if test $commit_status -ne 0
        # Check if it's because there's nothing to commit
        if git -C "$base_dir" diff-index --quiet HEAD --
            set_color yellow
            echo "  ℹ Nothing to commit"
            set_color normal
        else
            set_color red
            echo "  ✗ git commit failed"
            set_color normal
            set_color brblack
            echo "    Please commit and push manually from: $base_dir"
            set_color normal
            return 1
        end
    end

    # Pull
    set_color brblack
    echo "  → git pull"
    set_color normal
    git -C "$base_dir" pull --quiet
    if test $status -ne 0
        set_color red
        echo "  ✗ git pull failed"
        set_color normal
        set_color brblack
        echo "    Please resolve conflicts and push manually from: $base_dir"
        set_color normal
        return 1
    end

    # Push
    set_color brblack
    echo "  → git push"
    set_color normal
    git -C "$base_dir" push --quiet
    if test $status -ne 0
        set_color red
        echo "  ✗ git push failed"
        set_color normal
        set_color brblack
        echo "    Please push manually from: $base_dir"
        set_color normal
        return 1
    end

    echo ""
    set_color green
    echo "  ✓ Changes committed and pushed"
    set_color normal
    return 0
end
