#!/usr/bin/env bash
# Todoist urgent tasks indicator segment for tmux-powerline
# Shows "TODO" when urgent tasks are present

run_segment() {
    # Check if urgent-status.sh exists and is executable
    local urgent_script="/home/jumski/.dotfiles/todoist-helper/bin/urgent-status.sh"

    if [[ ! -x "$urgent_script" ]]; then
        return 1
    fi

    # urgent-status.sh exits 0 if no urgent tasks, non-zero if urgent tasks exist
    if ! "$urgent_script" >/dev/null 2>&1; then
        # Urgent tasks detected - output indicator
        echo "TODO"
    fi
    # If no urgent tasks, output nothing (segment will be hidden)

    return 0
}
