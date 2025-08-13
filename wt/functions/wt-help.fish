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
    printf "%-28s" "init <repo-url> [name]"
    set_color normal
    echo "clone and set up worktree structure"
    echo -n "    "
    set_color cyan
    printf "%-28s" "clone <repo-url> [name]"
    set_color normal
    echo "alias for init"
    echo ""
    
    # Worktree Operations
    set_color white
    echo "  worktree operations"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "new <name> [options]"
    set_color normal
    echo "create new worktree (or checkout remote)"
    echo -n "      "
    set_color brblack
    printf "%-26s" "--from <base>"
    set_color normal
    echo "base branch (default: trunk)"
    echo -n "      "
    set_color brblack
    printf "%-26s" "--force-new"
    set_color normal
    echo "skip remote check, always create new"
    echo -n "      "
    set_color brblack
    printf "%-26s" "--switch"
    set_color normal
    echo "open in muxit after creation"
    echo -n "    "
    set_color cyan
    printf "%-28s" "list"
    set_color normal
    echo "list all worktrees"
    echo -n "    "
    set_color cyan
    printf "%-28s" "switch <name>"
    set_color normal
    echo "open worktree in muxit (no cd)"
    echo -n "    "
    set_color cyan
    printf "%-28s" "remove <name>"
    set_color normal
    echo "remove worktree (auto-detects current)"
    echo ""
    
    # Stack Operations
    set_color white
    echo "  stack operations"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "stack list"
    set_color normal
    echo "show all stacks"
    echo -n "    "
    set_color cyan
    printf "%-28s" "stack sync [name]"
    set_color normal
    echo "sync entire stack"
    echo -n "    "
    set_color cyan
    printf "%-28s" "restack"
    set_color normal
    echo "rebase current stack"
    echo ""
    
    # Navigation
    set_color white
    echo "  navigation"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "up"
    set_color normal
    echo "switch to upstack worktree"
    echo -n "    "
    set_color cyan
    printf "%-28s" "down"
    set_color normal
    echo "switch to downstack worktree"
    echo -n "    "
    set_color cyan
    printf "%-28s" "bottom"
    set_color normal
    echo "switch to stack base"
    echo ""
    
    # Development
    set_color white
    echo "  development"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "status [--all]"
    set_color normal
    echo "show worktree status"
    echo -n "    "
    set_color cyan
    printf "%-28s" "sync [--all] [--force]"
    set_color normal
    echo "sync with remote"
    echo -n "    "
    set_color cyan
    printf "%-28s" "submit"
    set_color normal
    echo "submit stack to GitHub"
    echo ""
    
    # Environment
    set_color white
    echo "  environment"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "env sync [--all]"
    set_color normal
    echo "copy environment files"
    echo ""
    
    # Git Operations
    set_color white
    echo "  git operations"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "git <args>"
    set_color normal
    echo "run git commands in bare repository"
    echo ""
    
    # Other
    set_color white
    echo "  other"
    set_color normal
    echo -n "    "
    set_color cyan
    printf "%-28s" "help"
    set_color normal
    echo "show this help"
    echo -n "    "
    set_color cyan
    printf "%-28s" "version"
    set_color normal
    echo "show version"
    echo ""
end