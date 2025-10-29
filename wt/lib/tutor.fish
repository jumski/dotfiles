#!/usr/bin/env fish
# Tutorial helper functions for wt tutor command

function _wt_tutor_menu
    echo ""
    set_color bryellow
    echo "  📚 wt tutor - Interactive Workflow Tutorials"
    set_color normal
    echo ""

    echo "  Available tutorials:"
    echo ""

    set_color cyan
    printf "    %-20s" "init"
    set_color normal
    echo "Initialize new local repositories from scratch"

    set_color cyan
    printf "    %-20s" "fork"
    set_color normal
    echo "Forking repositories with gh CLI and wt clone"

    set_color cyan
    printf "    %-20s" "clone"
    set_color normal
    echo "Cloning repositories with worktree structure"

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

function _wt_tutor_clone
    echo ""
    set_color bryellow
    echo "📦 Tutorial: Cloning Repositories"
    set_color normal
    echo ""

    echo "Clone repositories with worktree structure in various formats:"
    echo ""

    set_color brgreen
    echo "Basic Formats:"
    set_color normal
    echo ""

    echo "  1. Full URL → default location (~/Code/org/repo)"
    set_color brblack
    echo "     wt clone https://github.com/org/repo"
    set_color normal
    echo ""

    echo "  2. Short format → default location (~/Code/org/repo)"
    set_color brblack
    echo "     wt clone org/repo"
    set_color normal
    echo ""

    echo "  3. SSH URL → default location"
    set_color brblack
    echo "     wt clone git@github.com:org/repo.git"
    set_color normal
    echo ""

    set_color brgreen
    echo "With Custom Location:"
    set_color normal
    echo ""

    echo "  4. Clone to custom relative path"
    set_color brblack
    echo "     wt clone org/repo ./my-custom-name"
    set_color normal
    echo ""

    echo "  5. Clone to custom absolute path"
    set_color brblack
    echo "     wt clone org/repo ~/projects/my-repo"
    set_color normal
    echo ""

    set_color brgreen
    echo "With Auto-Switch (--switch flag):"
    set_color normal
    echo ""

    echo "  6. Clone and immediately switch to main worktree"
    set_color brblack
    echo "     wt clone org/repo --switch"
    set_color normal
    echo ""

    echo "  7. Clone to custom location and switch"
    set_color brblack
    echo "     wt clone org/repo ./custom-name --switch"
    set_color normal
    echo ""

    set_color bryellow
    echo "💡 What gets created:"
    set_color normal
    echo "   repo/"
    echo "   ├── .bare/              # bare git repository"
    echo "   ├── worktrees/"
    echo "   │   └── main/          # main branch worktree"
    echo "   ├── envs/              # environment files"
    echo "   ├── .wt-config         # wt configuration"
    echo "   └── .wt-post-create    # post-creation hook"
    echo ""

    set_color bryellow
    echo "💡 After cloning:"
    set_color normal
    echo "   cd repo/worktrees/main      # Navigate to main worktree"
    echo "   wt new feature-name         # Create new worktree"
    echo "   wt switch feature-name      # Switch to worktree"
    echo ""

    set_color brred
    echo "⚠️  Note about --switch:"
    set_color normal
    echo "   • WITHOUT --switch: Clone only, stay in current directory"
    echo "   • WITH --switch: Clone and open main worktree in tmux"
    echo ""
end

function _wt_tutor_init
    echo ""
    set_color bryellow
    echo "🌱 Tutorial: Initializing New Local Repositories"
    set_color normal
    echo ""

    echo "Create brand new repositories with worktree structure (no cloning):"
    echo ""

    set_color brgreen
    echo "Basic Usage:"
    set_color normal
    echo ""

    echo "  1. Simple repo name → default location (~/Code/repo-name)"
    set_color brblack
    echo "     wt init my-project"
    set_color normal
    echo "     # Creates: ~/Code/my-project/"
    echo ""

    echo "  2. Initialize in current directory"
    set_color brblack
    echo "     wt init ./my-experiment"
    set_color normal
    echo "     # Creates: ./my-experiment/"
    echo ""

    echo "  3. Initialize with relative path"
    set_color brblack
    echo "     wt init projects/prototype"
    set_color normal
    echo "     # Creates: ./projects/prototype/"
    echo ""

    echo "  4. Initialize with absolute path"
    set_color brblack
    echo "     wt init /home/user/experiments/test-repo"
    set_color normal
    echo "     # Creates: /home/user/experiments/test-repo/"
    echo ""

    set_color brgreen
    echo "With Auto-Switch (--switch flag):"
    set_color normal
    echo ""

    echo "  5. Initialize and immediately open in tmux"
    set_color brblack
    echo "     wt init my-project --switch"
    set_color normal
    echo "     # Creates repo AND switches to main worktree"
    echo ""

    echo "  6. Initialize in custom location and switch"
    set_color brblack
    echo "     wt init ~/sandbox/quick-test --switch"
    set_color normal
    echo ""

    set_color brgreen
    echo "Common Use Cases:"
    set_color normal
    echo ""

    echo "  💡 Personal projects"
    set_color brblack
    echo "     wt init personal/blog-redesign"
    set_color normal
    echo ""

    echo "  💡 Quick experiments"
    set_color brblack
    echo "     wt init ./temp-test --switch"
    set_color normal
    echo ""

    echo "  💡 Monorepo setup"
    set_color brblack
    echo "     wt init company/monorepo"
    echo "     cd company/monorepo/worktrees/main"
    echo "     # Set up your monorepo structure"
    set_color normal
    echo ""

    echo "  💡 Fork workflow (init locally first)"
    set_color brblack
    echo "     wt init upstream-name"
    echo "     cd upstream-name/worktrees/main"
    echo "     git remote add upstream git@github.com:org/repo.git"
    echo "     git fetch upstream"
    echo "     git reset --hard upstream/main"
    set_color normal
    echo ""

    set_color bryellow
    echo "📁 Directory Structure Created:"
    set_color normal
    echo "   my-project/"
    echo "   ├── .bare/              # bare git repository"
    echo "   │   └── ...            # git objects, refs, etc."
    echo "   ├── worktrees/"
    echo "   │   └── main/          # main branch worktree"
    echo "   │       └── ...        # your actual code goes here"
    echo "   ├── envs/              # environment files (.env, etc.)"
    echo "   ├── .wt-config         # wt configuration"
    echo "   └── .wt-post-create    # post-creation hook script"
    echo ""

    set_color bryellow
    echo "🚀 What Gets Set Up:"
    set_color normal
    echo "   ✓ Bare git repository initialized"
    echo "   ✓ Main worktree with initial empty commit"
    echo "   ✓ Graphite (gt) initialized for stack management"
    echo "   ✓ .wt-config file with repository settings"
    echo "   ✓ .wt-post-create hook for automation"
    echo "   ✓ Ready for your first real commit"
    echo ""

    set_color bryellow
    echo "💡 After initialization:"
    set_color normal
    echo "   cd my-project/worktrees/main    # Navigate to main worktree"
    echo "   # Add your initial code"
    echo "   git add ."
    echo "   git commit -m 'Initial commit'"
    echo "   wt new feature-name             # Create feature worktree"
    echo "   wt switch feature-name          # Start working"
    echo ""

    set_color bryellow
    echo "🔄 init vs clone:"
    set_color normal
    echo "   • wt init  → Create NEW local repository from scratch"
    echo "   • wt clone → Copy EXISTING remote repository"
    echo ""

    set_color brred
    echo "⚠️  Important Notes:"
    set_color normal
    echo "   • Init creates a truly empty repo (one empty commit on main)"
    echo "   • Use clone if you want to work with existing remote repos"
    echo "   • Use init for brand new projects or local experimentation"
    echo "   • --switch opens in tmux, without it you stay in current dir"
    echo "   • Path format determines location (name → ~/Code, ./ → current dir)"
    echo ""
end

function _wt_tutor_fork
    echo ""
    set_color bryellow
    echo "🍴 Tutorial: Forking Repositories"
    set_color normal
    echo ""

    echo "Fork a repository on GitHub and clone it with worktree structure:"
    echo ""

    set_color brgreen
    echo "Basic Fork Workflow (Recommended):"
    set_color normal
    echo ""

    echo "  1. Fork the repo on GitHub (without cloning)"
    set_color brblack
    echo "     gh repo fork org/repo-name"
    set_color normal
    echo "     # Creates fork at your-username/repo-name"
    echo ""

    echo "  2. Clone YOUR fork with wt"
    set_color brblack
    echo "     wt clone your-username/repo-name"
    set_color normal
    echo "     # Or use short format if gh CLI is available:"
    set_color brblack
    echo "     wt clone repo-name"
    set_color normal
    echo ""

    echo "  3. Add upstream remote"
    set_color brblack
    echo "     cd repo-name/worktrees/main"
    echo "     git remote add upstream git@github.com:org/repo-name.git"
    echo "     git fetch upstream"
    set_color normal
    echo ""

    echo "  4. Keep your fork in sync"
    set_color brblack
    echo "     git checkout main"
    echo "     git pull upstream main"
    echo "     git push origin main"
    set_color normal
    echo ""

    set_color brgreen
    echo "Quick Fork + Clone (with --switch):"
    set_color normal
    echo ""

    echo "  1. Fork and clone in one flow"
    set_color brblack
    echo "     gh repo fork org/repo-name"
    echo "     wt clone your-username/repo-name --switch"
    set_color normal
    echo "     # Forks, clones, and opens in tmux"
    echo ""

    set_color brgreen
    echo "Fork with Custom Settings:"
    set_color normal
    echo ""

    echo "  💡 Fork to custom location"
    set_color brblack
    echo "     gh repo fork org/repo-name"
    echo "     wt clone your-username/repo-name ~/projects/my-fork"
    set_color normal
    echo ""

    echo "  💡 Fork with renamed repository"
    set_color brblack
    echo "     gh repo fork org/repo-name --fork-name my-custom-name"
    echo "     wt clone your-username/my-custom-name"
    set_color normal
    echo ""

    echo "  💡 Fork to organization"
    set_color brblack
    echo "     gh repo fork org/repo-name --org your-org-name"
    echo "     wt clone your-org-name/repo-name"
    set_color normal
    echo ""

    echo "  💡 Fork default branch only (smaller/faster)"
    set_color brblack
    echo "     gh repo fork org/repo-name --default-branch-only"
    echo "     wt clone your-username/repo-name"
    set_color normal
    echo ""

    set_color brgreen
    echo "Working on Your Fork:"
    set_color normal
    echo ""

    echo "  1. Create feature branch"
    set_color brblack
    echo "     wt new feature-name"
    echo "     wt switch feature-name"
    set_color normal
    echo ""

    echo "  2. Make changes and commit"
    set_color brblack
    echo "     # ... make changes ..."
    echo "     git add ."
    echo "     git commit -m 'feat: add new feature'"
    set_color normal
    echo ""

    echo "  3. Push to your fork"
    set_color brblack
    echo "     git push -u origin feature-name"
    set_color normal
    echo ""

    echo "  4. Create pull request"
    set_color brblack
    echo "     gh pr create --repo org/repo-name"
    set_color normal
    echo "     # Creates PR from your fork to upstream"
    echo ""

    set_color brgreen
    echo "Syncing with Upstream:"
    set_color normal
    echo ""

    echo "  💡 Update your main from upstream"
    set_color brblack
    echo "     cd repo-name/worktrees/main"
    echo "     git checkout main"
    echo "     git fetch upstream"
    echo "     git merge upstream/main"
    echo "     git push origin main"
    set_color normal
    echo ""

    echo "  💡 Rebase your feature on latest upstream"
    set_color brblack
    echo "     wt switch feature-name"
    echo "     git fetch upstream"
    echo "     git rebase upstream/main"
    echo "     git push --force-with-lease"
    set_color normal
    echo ""

    set_color bryellow
    echo "📁 Resulting Structure:"
    set_color normal
    echo "   repo-name/                     # ~/Code/your-username/repo-name"
    echo "   ├── .bare/                     # bare git repository"
    echo "   ├── worktrees/"
    echo "   │   ├── main/                 # your fork's main branch"
    echo "   │   └── feature-name/         # your feature worktree"
    echo "   ├── envs/"
    echo "   ├── .wt-config"
    echo "   └── .wt-post-create"
    echo ""

    set_color bryellow
    echo "🔄 Git Remotes Setup:"
    set_color normal
    echo "   origin     → git@github.com:your-username/repo-name.git  (your fork)"
    echo "   upstream   → git@github.com:org/repo-name.git           (original)"
    echo ""

    set_color bryellow
    echo "💡 Why This Approach:"
    set_color normal
    echo "   ✓ gh repo fork creates fork on GitHub without local clone"
    echo "   ✓ wt clone sets up proper worktree structure"
    echo "   ✓ Keeps your local disk clean (no abandoned clones)"
    echo "   ✓ Integrates with wt/gt workflow from the start"
    echo "   ✓ Easy to sync with upstream using git commands"
    echo ""

    set_color brred
    echo "⚠️  Important Notes:"
    set_color normal
    echo "   • DON'T use 'gh repo fork --clone' (conflicts with wt structure)"
    echo "   • Always fork first, THEN wt clone your fork"
    echo "   • Add upstream remote to track original repository"
    echo "   • Use 'gh pr create --repo org/repo' to create PRs to upstream"
    echo "   • Keep your main in sync with upstream/main regularly"
    echo ""

    set_color bryellow
    echo "🆚 Fork vs Clone:"
    set_color normal
    echo "   • wt clone org/repo    → Clone original (read-only contribution)"
    echo "   • gh repo fork + wt    → Fork then clone (full control + PRs)"
    echo ""
end
