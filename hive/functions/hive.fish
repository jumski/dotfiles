#!/usr/bin/env fish
# Hive - Main facade/dispatcher

function hive
    set -l command $argv[1]
    set -l remaining_args $argv[2..-1]

    switch $command
        case spawn sp
            hive_spawn $remaining_args
        case session ses
            hive_session $remaining_args
        case window win
            hive_window $remaining_args
        case split
            hive_split $remaining_args
        case list ls
            hive_list $remaining_args
        case version --version -v
            echo "hive version $HIVE_VERSION"
        case help --help -h ''
            _hive_help
        case '*'
            echo "Unknown command: $command"
            _hive_help
            return 1
    end
end

function _hive_help
    set -l dim (set_color brblack)
    set -l cyan (set_color cyan)
    set -l green (set_color green)
    set -l yellow (set_color yellow)
    set -l magenta (set_color magenta)
    set -l bold (set_color --bold)
    set -l r (set_color normal)

    echo ""
    echo $bold"Hive"$r" - Tmux workspace management for agentic coding"
    echo ""
    echo $dim"Organize multiple directories in a single tmux session."$r
    echo $dim"Each repo gets one session, each directory gets a window."$r
    echo ""
    echo $yellow"USAGE"$r
    echo "  hive <command> [args]"
    echo ""
    echo $yellow"COMMANDS"$r
    echo "  "$green"spawn"$r", "$dim"sp"$r"      Interactive wizard - pick path, pick destination"
    echo "  "$green"session"$r", "$dim"ses"$r"   Create new hive session from a directory"
    echo "  "$green"window"$r", "$dim"win"$r"    Add window to existing hive session"
    echo "  "$green"split"$r"          Split current window with another directory"
    echo "  "$green"list"$r", "$dim"ls"$r"       List all hive sessions and their windows"
    echo ""
    echo $yellow"OPTIONS"$r
    echo "  "$cyan"--help"$r", "$cyan"-h"$r"      Show this help"
    echo "  "$cyan"--version"$r", "$cyan"-v"$r"   Show version"
    echo ""
    echo $yellow"COMMON FLAGS"$r
    echo "  "$cyan"--path <path>"$r"          Arbitrary directory (skip picker)"
    echo "  "$cyan"--session-name <name>"$r"   Custom session name"
    echo "  "$cyan"--window-name <name>"$r"    Custom window name"
    echo ""
    echo $yellow"EXAMPLES"$r
    echo ""
    echo "  "$dim"# Launch interactive wizard (also: prefix + h in tmux)"$r
    echo "  \$ "$bold"hive spawn"$r
    echo ""
    echo "  "$dim"# Create hive session for current directory"$r
    echo "  \$ "$bold"hive session ."$r
    echo ""
    echo "  "$dim"# Create hive session for a specific path"$r
    echo "  \$ "$bold"hive session --path ~/path/to/project"$r
    echo ""
    echo "  "$dim"# Create session with custom names"$r
    echo "  \$ "$bold"hive session . --session-name myapp --window-name main"$r
    echo ""
    echo "  "$dim"# Add window with custom name to current session"$r
    echo "  \$ "$bold"hive window ~/other/path --window-name tools"$r
    echo ""
    echo "  "$dim"# Add window to a specific session"$r
    echo "  \$ "$bold"hive window ~/Code/org/repo/worktrees/main pgflow"$r
    echo ""
    echo "  "$dim"# Split current window side-by-side with another path"$r
    echo "  \$ "$bold"hive split ~/path/to/other"$r
    echo ""
    echo "  "$dim"# See all hive sessions"$r
    echo "  \$ "$bold"hive list"$r
    echo ""
    echo $yellow"NAMING"$r
    echo "  Session = repo name      "$dim"(e.g., pgflow, dotfiles)"$r
    echo "  Window  = directory name "$dim"(e.g., main, feat-auth, docs)"$r
    echo "  Duplicate windows auto-suffix (-2, -3, ...)"
    echo ""
    echo $yellow"PICKER"$r
    echo "  The spawn wizard offers:"
    echo "  - Current directory (preselected)"
    echo "  - Custom path (enter any directory)"
    echo "  - Known worktrees from ~/.cache/muxit-projects"
    echo ""
    echo $yellow"NOTIFICATIONS"$r
    echo "  Windows show badges when agents need attention:"
    echo "  "$magenta"[R]"$r" Permission needed  "$magenta"[I]"$r" Idle/waiting"
    echo "  "$magenta"[!]"$r" Error occurred     "$magenta"[A]"$r" Activity"
    echo ""
end
