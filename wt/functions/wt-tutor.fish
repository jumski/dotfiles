#!/usr/bin/env fish
# Interactive tutorials for wt/gt workflow

function wt_tutor
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt tutor [topic]

Interactive tutorials for wt/gt workflow

Topics:
  hotfix         Creating urgent fixes on main branch
  update         Syncing all stacks after merging changes
  branch         Creating a new feature branch
  stack          Creating next branch in a stack
  commit         Committing with amend workflows
  fork-pr        Converting fork PR to origin branch for wt/gt
  workflow       Complete development workflow walkthrough

Run 'wt tutor' with no arguments to see the interactive menu."
    and return 0

    set -l topic $argv[1]

    if test -z "$topic"
        _wt_tutor_menu
        return
    end
    
    switch $topic
        case hotfix main-hotfix
            _wt_tutor_main_hotfix
        case update sync-all update-all
            _wt_tutor_update_all_stacks
        case branch new-branch
            _wt_tutor_new_branch
        case stack stack-branch next-branch
            _wt_tutor_stack_branch
        case commit amend commit-amend
            _wt_tutor_commit_amend
        case fork-pr fork pr-fork
            _wt_tutor_fork_pr
        case doctor fix troubleshoot
            _wt_tutor_doctor
        case workflow full-workflow
            _wt_tutor_full_workflow
        case list menu
            _wt_tutor_menu
        case '*'
            echo "Unknown tutorial topic: $topic"
            _wt_tutor_menu
            return 1
    end
end

function _wt_tutor_menu
    echo ""
    set_color bryellow
    echo "  📚 wt tutor - Interactive Workflow Tutorials"
    set_color normal
    echo ""
    
    echo "  Available tutorials:"
    echo ""
    
    set_color cyan
    printf "    %-20s" "hotfix"
    set_color normal
    echo "Creating urgent fixes on main branch"
    
    set_color cyan
    printf "    %-20s" "update"
    set_color normal
    echo "Syncing all stacks after merging changes"
    
    set_color cyan
    printf "    %-20s" "branch"
    set_color normal
    echo "Creating a new feature branch"
    
    set_color cyan
    printf "    %-20s" "stack"
    set_color normal
    echo "Creating next branch in a stack"
    
    set_color cyan
    printf "    %-20s" "commit"
    set_color normal
    echo "Committing with amend workflows"

    set_color cyan
    printf "    %-20s" "fork-pr"
    set_color normal
    echo "Converting fork PR to origin branch for wt/gt"

    set_color cyan
    printf "    %-20s" "doctor"
    set_color normal
    echo "Diagnosing and fixing repository issues"

    set_color cyan
    printf "    %-20s" "workflow"
    set_color normal
    echo "Complete development workflow walkthrough"

    echo ""
    set_color brblack
    echo "  Usage: wt tutor <topic>"
    set_color normal
    echo ""
end

function _wt_tutor_main_hotfix
    echo ""
    set_color bryellow
    echo "🚨 Tutorial: Main Branch Hotfix"
    set_color normal
    echo ""
    
    echo "When you need to create an urgent fix directly on main:"
    echo ""
    
    set_color brgreen
    echo "1. Create hotfix worktree from main:"
    set_color normal
    echo "   wt new hotfix-issue-123 --from main"
    echo ""
    
    set_color brgreen
    echo "2. Switch to the hotfix worktree:"
    set_color normal
    echo "   wt switch hotfix-issue-123"
    echo ""
    
    set_color brgreen
    echo "3. Make your urgent changes and test"
    set_color normal
    echo ""
    
    set_color brgreen
    echo "4. Commit the fix:"
    set_color normal
    echo "   git add ."
    echo "   git commit -m 'hotfix: fix critical issue #123'"
    echo ""
    
    set_color brgreen
    echo "5. Push and create PR to main:"
    set_color normal
    echo "   git push -u origin hotfix-issue-123"
    echo "   gh pr create --base main --title 'Hotfix: Critical issue #123'"
    echo ""
    
    set_color brgreen
    echo "6. After merge, update all your other stacks:"
    set_color normal
    echo "   wt tutor update"
    echo ""
    
    set_color bryellow
    echo "💡 Tip: Use --switch flag to automatically open in muxit:"
    set_color normal
    echo "   wt new hotfix-issue-123 --from main --switch"
    echo ""
end

function _wt_tutor_update_all_stacks
    echo ""
    set_color bryellow
    echo "🔄 Tutorial: Update All Stacks After Merge"
    set_color normal
    echo ""
    
    echo "After changes are merged to main, update all your stacks:"
    echo ""
    
    set_color brgreen
    echo "1. Sync main branch across all worktrees:"
    set_color normal
    echo "   wt sync-all"
    echo ""

    set_color brgreen
    echo "2. Update all stack bases using gt:"
    set_color normal
    echo "   # In each worktree with a stack:"
    echo "   gt stack rebase"
    echo ""

    set_color brgreen
    echo "3. Check all stacks are up to date:"
    set_color normal
    echo "   # In each worktree:"
    echo "   gt stack"
    echo ""

    set_color bryellow
    echo "💡 Pro tip: Use gt to rebase and submit stacks:"
    set_color normal
    echo "   gt stack rebase && gt submit --stack"
    echo ""
    
    set_color brred
    echo "⚠️  Always sync before starting new work to avoid conflicts"
    set_color normal
    echo ""
end

function _wt_tutor_new_branch
    echo ""
    set_color bryellow
    echo "🌱 Tutorial: Creating New Feature Branch"
    set_color normal
    echo ""
    
    echo "Starting a new feature branch:"
    echo ""
    
    set_color brgreen
    echo "1. Ensure main is up to date:"
    set_color normal
    echo "   gt sync"
    echo ""
    
    set_color brgreen
    echo "2. Create new worktree from main:"
    set_color normal
    echo "   wt new feature-awesome-thing --from main --switch"
    echo ""
    
    set_color brgreen
    echo "3. Initialize the branch in gt (automatic in wt new):"
    set_color normal
    echo "   gt branch create feature-awesome-thing"
    echo ""
    
    set_color brgreen
    echo "4. Start developing:"
    set_color normal
    echo "   # Make changes, add files..."
    echo "   git add ."
    echo "   git commit -m 'feat: add awesome thing'"
    echo ""
    
    set_color brgreen
    echo "5. Submit when ready:"
    set_color normal
    echo "   gt submit --stack"
    echo ""
    
    set_color bryellow
    echo "💡 Branch naming conventions:"
    set_color normal
    echo "   • feature-description"
    echo "   • fix-issue-number"
    echo "   • refactor-component-name"
    echo ""
end

function _wt_tutor_stack_branch
    echo ""
    set_color bryellow
    echo "📚 Tutorial: Creating Next Branch in Stack"
    set_color normal
    echo ""
    
    echo "Building on top of existing branch in a stack:"
    echo ""
    
    set_color brgreen
    echo "1. Create stacked branch with worktree (recommended):"
    set_color normal
    echo "   # From feature-part-1 worktree:"
    echo "   wt branch feature-part-2 -m 'feat: add part 2' --switch"
    echo "   # Creates new branch stacked on current, with worktree"
    echo ""
    
    set_color brgreen
    echo "2. Alternative: manual worktree creation:"
    set_color normal
    echo "   wt new feature-part-2 --from feature-part-1"
    echo ""
    
    set_color brgreen
    echo "3. Alternative: use gt in current worktree:"
    set_color normal
    echo "   gt branch create feature-part-2"
    echo "   # This creates new branch in same worktree"
    echo ""
    
    set_color brgreen
    echo "4. Develop the next part:"
    set_color normal
    echo "   git add ."
    echo "   git commit -m 'feat: extend awesome thing with part 2'"
    echo ""
    
    set_color brgreen
    echo "5. Submit entire stack:"
    set_color normal
    echo "   gt stack submit  # submits all branches in stack"
    echo ""
    
    set_color bryellow
    echo "💡 Stack benefits:"
    set_color normal
    echo "   • Smaller, focused PRs"
    echo "   • Faster reviews"
    echo "   • Parallel development"
    echo ""
end

function _wt_tutor_commit_amend
    echo ""
    set_color bryellow
    echo "✏️  Tutorial: Commit with Amend Workflows"
    set_color normal
    echo ""
    
    echo "Common commit and amend patterns:"
    echo ""
    
    set_color brgreen
    echo "1. Regular commit:"
    set_color normal
    echo "   git add ."
    echo "   git commit -m 'feat: add new feature'"
    echo ""
    
    set_color brgreen
    echo "2. Amend last commit (add more changes):"
    set_color normal
    echo "   # Make more changes"
    echo "   git add ."
    echo "   git commit --amend --no-edit"
    echo ""
    
    set_color brgreen
    echo "3. Amend commit message:"
    set_color normal
    echo "   git commit --amend -m 'feat: improve new feature'"
    echo ""
    
    set_color brgreen
    echo "4. Interactive rebase for older commits:"
    set_color normal
    echo "   git rebase -i HEAD~3  # edit last 3 commits"
    echo ""
    
    set_color brgreen
    echo "5. Using gt for stack management:"
    set_color normal
    echo "   gt commit create -m 'feat: add feature'  # better than git commit"
    echo "   gt commit amend  # amend with gt"
    echo ""
    
    set_color bryellow
    echo "💡 When to amend vs new commit:"
    set_color normal
    echo "   • Amend: fixing typos, adding forgotten files"
    echo "   • New commit: logical changes, new functionality"
    echo ""
    
    set_color brred
    echo "⚠️  Never amend commits already pushed to shared branches"
    set_color normal
    echo ""
end

function _wt_tutor_fork_pr
    echo ""
    set_color bryellow
    echo "🔀 Tutorial: Converting Fork PR to Origin Branch"
    set_color normal
    echo ""

    echo "Work with fork PRs locally using wt/gt by creating origin branches:"
    echo ""

    set_color brgreen
    echo "1. Find the PR number you want to work with:"
    set_color normal
    echo "   # Check GitHub for the PR number (e.g., #229)"
    echo ""

    set_color brgreen
    echo "2. Fetch the PR ref directly into a new branch:"
    set_color normal
    echo "   git fetch origin pull/229/head:restore-toml-patch-comments"
    echo "   # This creates a local branch from the fork's PR"
    echo ""

    set_color brgreen
    echo "3. Push the branch to origin:"
    set_color normal
    echo "   git push -u origin restore-toml-patch-comments"
    echo "   # Now it's a regular origin branch"
    echo ""

    set_color brgreen
    echo "4. Create a worktree for the branch:"
    set_color normal
    echo "   wt new restore-toml-patch-comments --from restore-toml-patch-comments --switch"
    echo "   # Or if the branch already exists:"
    echo "   wt checkout restore-toml-patch-comments --switch"
    echo ""

    set_color brgreen
    echo "5. Work with it normally using wt/gt:"
    set_color normal
    echo "   # Make changes..."
    echo "   git add ."
    echo "   git commit -m 'feat: improve PR'"
    echo "   git push"
    echo ""

    set_color bryellow
    echo "💡 Why this works:"
    set_color normal
    echo "   • Fork PRs don't exist as origin branches by default"
    echo "   • Fetching pull/N/head gives you the PR's HEAD commit"
    echo "   • Creating and pushing a branch makes it trackable"
    echo "   • Now you can use wt, gt, and normal git workflows"
    echo ""

    set_color brred
    echo "⚠️  Considerations:"
    set_color normal
    echo "   • This creates a new branch in your repo"
    echo "   • Original PR author won't see your commits"
    echo "   • You'll need to coordinate or create your own PR"
    echo "   • Useful for testing, reviewing, or building on fork PRs"
    echo ""
end

function _wt_tutor_doctor
    echo ""
    set_color bryellow
    echo "🔧 Tutorial: Diagnosing Repository Issues"
    set_color normal
    echo ""

    echo "Use wt doctor to detect and fix common repository issues:"
    echo ""

    set_color brgreen
    echo "1. Run diagnostic check:"
    set_color normal
    echo "   wt doctor"
    echo "   # Scans for issues like missing fetch refspecs, broken worktrees"
    echo ""

    set_color brgreen
    echo "2. Auto-fix detected issues:"
    set_color normal
    echo "   wt doctor --fix"
    echo "   # Automatically repairs common configuration problems"
    echo ""

    set_color brgreen
    echo "3. Check a specific repository:"
    set_color normal
    echo "   wt doctor ~/Code/my-project"
    echo "   wt doctor --fix ~/Code/my-project"
    echo ""

    set_color bryellow
    echo "💡 Common issues detected:"
    set_color normal
    echo "   • Missing remote.origin.fetch refspec (breaks git fetch)"
    echo "   • Missing worktrees or envs directories"
    echo "   • Orphaned worktree references"
    echo "   • Invalid bare repository configuration"
    echo ""

    set_color brgreen
    echo "When to use:"
    set_color normal
    echo "   • After cloning older wt repositories"
    echo "   • Git fetch or sync commands failing"
    echo "   • Setting up repositories on a new machine"
    echo "   • Strange git remote tracking issues"
    echo ""
end

function _wt_tutor_full_workflow
    echo ""
    set_color bryellow
    echo "🔄 Tutorial: Complete Development Workflow"
    set_color normal
    echo ""
    
    echo "End-to-end workflow for new feature development:"
    echo ""
    
    set_color brgreen
    echo "Phase 1: Setup"
    set_color normal
    echo "1. wt sync-all                      # sync everything"
    echo "2. wt new feature-auth --switch     # create & switch to new worktree"
    echo ""
    
    set_color brgreen
    echo "Phase 2: Development"
    set_color normal
    echo "3. # Implement feature..."
    echo "4. git add ."
    echo "5. git commit -m 'feat: add authentication'"
    echo "6. # Continue developing, committing..."
    echo ""
    
    set_color brgreen
    echo "Phase 3: Stack Building (if needed)"
    set_color normal
    echo "7. wt branch feature-auth-ui -m 'feat: add auth UI' --switch"
    echo "8. # Develop UI part..."
    echo "9. git commit -m 'feat: add auth UI components'"
    echo ""
    
    set_color brgreen
    echo "Phase 4: Review & Submit"
    set_color normal
    echo "10. gt stack submit                 # create PRs for entire stack"
    echo "11. # Address review feedback..."
    echo "12. git commit --amend --no-edit    # or new commits"
    echo "13. git push --force-with-lease     # update PR"
    echo ""
    
    set_color brgreen
    echo "Phase 5: After Merge"
    set_color normal
    echo "14. wt sync-all                     # sync main across worktrees"
    echo "15. wt remove feature-auth          # cleanup merged worktrees"
    echo "16. wt remove feature-auth-ui"
    echo ""
    
    set_color bryellow
    echo "💡 Key principles:"
    set_color normal
    echo "   • Always sync before starting"
    echo "   • Use stacks for related changes"
    echo "   • Keep commits focused and clear"
    echo "   • Clean up merged worktrees"
    echo ""
end