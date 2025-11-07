#!/usr/bin/env fish
# Help text

function _wt_help
    # Title
    echo ""
    set_color brblack
    echo -n "  "
    set_color bryellow
    echo -n "wt"
    set_color white
    echo " - worktree toolkit for graphite"
    set_color normal
    echo ""
    
    set_color white
    echo "  Usage: wt <command> [options]"
    set_color normal
    echo ""
    
    # Repository Management
    set_color white
    echo "  repository management"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "init <name>"
    set_color normal
    echo "initialize new local repository"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--switch"
    set_color normal
    echo "open main worktree in muxit after init"
    echo -n "    "
    set_color cyan
    printf "%-32s" "clone <repo-url> [name]"
    set_color normal
    echo "clone and set up worktree structure"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--switch"
    set_color normal
    echo "open main worktree in muxit after clone"
    echo ""

    # Worktree Operations
    set_color white
    echo "  worktree operations"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "new <name> [options]"
    set_color normal
    echo "create new worktree (or checkout remote)"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--from <base>"
    set_color normal
    echo "base branch (default: trunk)"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--trunk <branch>"
    set_color normal
    echo "trunk branch for graphite init"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--force-new"
    set_color normal
    echo "skip remote check, always create new"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--switch"
    set_color normal
    echo "open in muxit after creation"
    echo -n "    "
    set_color cyan
    printf "%-32s" "branch <name> [options] (br)"
    set_color normal
    echo "create new branch & worktree"
    echo -n "      "
    set_color brblack
    printf "%-30s" "-m <message>"
    set_color normal
    echo "commit message (with graphite)"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--switch"
    set_color normal
    echo "open in muxit after creation"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--yes, --force"
    set_color normal
    echo "skip confirmation prompts"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--require-clean"
    set_color normal
    echo "fail if repo has uncommitted changes"
    echo -n "      "
    set_color brblack
    printf "%-30s" "[gt options]"
    set_color normal
    echo "all gt create options (if graphite)"
    echo -n "    "
    set_color cyan
    printf "%-32s" "remove <name> (rm)"
    set_color normal
    echo "remove worktree (auto-detects current)"
    echo ""

    # Navigation
    set_color white
    echo "  navigation"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "switch <name> (sw)"
    set_color normal
    echo "open worktree in muxit (no cd)"
    echo ""

    # Development
    set_color white
    echo "  development"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "sync-all [--force] [--reset]"
    set_color normal
    echo "sync all worktrees with remote"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--force"
    set_color normal
    echo "stash uncommitted changes"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--reset"
    set_color normal
    echo "hard reset to origin branch"
    echo ""

    # Environment
    set_color white
    echo "  environment"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "env sync [--all]"
    set_color normal
    echo "copy environment files"
    echo ""

    # Git Operations
    set_color white
    echo "  git operations"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "git <args>"
    set_color normal
    echo "run git commands in bare repository"
    echo ""

    # Other
    set_color white
    echo "  other"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-32s" "doctor [--fix] [path]"
    set_color normal
    echo "diagnose and fix repository issues"
    echo -n "      "
    set_color brblack
    printf "%-30s" "--fix"
    set_color normal
    echo "automatically fix detected issues"
    echo -n "    "
    set_color cyan
    printf "%-32s" "tutor [topic]"
    set_color normal
    echo "interactive workflow tutorials"
    echo -n "    "
    set_color cyan
    printf "%-32s" "reload"
    set_color normal
    echo "reload wt functions and completions"
    echo -n "    "
    set_color cyan
    printf "%-32s" "help"
    set_color normal
    echo "show this help"
    echo -n "    "
    set_color cyan
    printf "%-32s" "version (--version, -v)"
    set_color normal
    echo "show version"
    echo ""
end