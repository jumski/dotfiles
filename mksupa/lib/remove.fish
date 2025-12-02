function __mksupa_remove -d "Stop and cleanup current supatemp project"
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"
    set -l current_dir $PWD

    # Validate we're in a supatemp subdirectory
    if not string match -q "$base_dir/*" $current_dir
        echo ""
        set_color red
        echo "✗ Error: Not in a supatemp directory"
        set_color normal
        echo ""
        set_color brblack
        echo "This command must be run from within a supatemp project directory:"
        echo "  $base_dir/<project>/"
        set_color normal
        echo ""
        return 1
    end

    # Ensure we're not at the base directory itself
    if test "$current_dir" = "$base_dir"
        echo ""
        set_color red
        echo "✗ Error: Cannot fold from supatemp base directory"
        set_color normal
        echo ""
        set_color brblack
        echo "Navigate into a specific project directory first"
        set_color normal
        echo ""
        return 1
    end

    # Get the project directory name for confirmation
    set -l relative_path (string replace "$base_dir/" "" $current_dir)
    set -l project_dir (string split -m 1 / $relative_path)[1]
    set -l project_path "$base_dir/$project_dir"

    echo ""
    set_color yellow
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🗑  Removing supatemp project: $project_dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    set_color normal
    echo ""

    # Stop Supabase
    set_color blue
    echo "⏹  Stopping Supabase..."
    set_color normal
    if test -x "$project_path/bin/supa"
        cd "$project_path"
        bin/supa stop --no-backup
    else
        set_color yellow
        echo "  ⚠ bin/supa not found, skipping stop"
        set_color normal
    end
    echo ""

    # Kill tmux session only if we're in a session matching the project
    if test -n "$TMUX"
        set -l current_session (tmux display-message -p '#S')
        # Only kill if current session contains the project name
        if string match -q "*$project_dir*" $current_session
            set_color blue
            echo "🔌 Killing tmux session: $current_session"
            set_color normal

            # Need to detach first, then kill in background
            # We'll switch to a different session or detach before killing
            tmux switch-client -n 2>/dev/null; or tmux detach-client
            tmux kill-session -t "$current_session" 2>/dev/null &
        else
            set_color brblack
            echo "  → Current session '$current_session' doesn't match project, keeping it"
            set_color normal
        end
    else
        set_color brblack
        echo "  → Not in tmux session, skipping"
        set_color normal
    end

    # Delete the project directory
    set_color red
    echo "🗑  Deleting project directory..."
    set_color normal
    rm -rf "$project_path"

    echo ""
    set_color green; set_color --bold
    echo "✨ Project removed successfully!"
    set_color normal
    echo ""
end
