# Worktree Toolkit (wt)

A Git worktree management system with Graphite integration for parallel stacked development.

## Nomenclature

- **Worktree** - A separate working directory linked to your Git repository, allowing multiple branches to be checked out simultaneously
- **Stack** - A series of dependent pull requests where each PR builds on the previous one (Graphite concept)
- **Base/Parent** - The branch that another branch is built on top of
- **Upstack/Downstack** - Branches above (upstack) or below (downstack) in the dependency chain
- **Trunk** - The main development branch (usually `main` or `master`)
- **Bare Repository** - A Git repository without a working directory, used as the source for all worktrees
- **Sync** - Updating local branches with remote changes and rebasing dependent branches as needed
- **PR** - Pull Request (GitHub) / Merge Request (GitLab)

## Quick Start

```bash
# Initialize a new local repository
wt init myproject

# Or clone an existing repository
wt clone git@github.com:org/repo.git myproject

# Create a new feature worktree
wt new feature-auth

# Sync all worktrees
wt sync-all
```

## Common Commands Cheatsheet

```bash
# Repository Management
wt init <name>               # Initialize new local repository
wt clone <repo-url> [name]   # Clone and set up worktree structure

# Worktree Operations
wt new <name>                # Create new worktree from main
wt new <name> --from <base>  # Create from specific branch
wt new <name> --switch       # Create and open in muxit
wt switch <name>             # Open worktree in muxit (doesn't cd)
wt switch                    # Interactive selection with fzf
wt remove <name>             # Remove worktree (prompts for confirmation)

# Stack Navigation (with automatic worktree switching)
wt up                        # Switch to upstack worktree via muxit
wt down                      # Switch to downstack worktree via muxit
wt bottom                    # Switch to stack base worktree via muxit

# Development Flow
wt sync-all                  # Sync all worktrees with remote
wt sync-all --force          # Sync all, stashing uncommitted changes
wt sync-all --reset          # Hard reset all worktrees to origin

# Environment Management
wt env sync                  # Copy latest envs/ to current worktree
wt env sync --all            # Update envs in all worktrees

```

## Why Worktree Toolkit?

Modern development often requires working on multiple interdependent features simultaneously:

- **Feature A** needs to be developed and reviewed
- **Feature B** depends on A but development can start in parallel
- **Feature C** is a quick bugfix unrelated to A or B

Traditional Git workflows force constant context switching via `git checkout`. Graphite helps with stacking but still requires jumping between branches.

**wt** combines Git worktrees with Graphite's stacking to enable truly parallel development:

```
myproject/
├── worktrees/
│   ├── main/           # Always clean main branch
│   ├── auth/           # Feature A: authentication system
│   ├── user-profiles/  # Feature B: built on auth
│   └── bugfix-123/     # Feature C: independent fix
```

Each worktree is a full checkout - edit different features in different editor windows, run tests in parallel, compare implementations side-by-side.

## Installation

```bash
# Install dependencies
brew install graphite
npm install -g @withgraphite/graphite-cli@stable

# Install wt
git clone https://github.com/yourusername/worktree-toolkit.git ~/.wt
echo 'source ~/.wt/init.fish' >> ~/.config/fish/config.fish

# Or via fisher
fisher install yourusername/worktree-toolkit
```

## Typical Workflow

### 1. Start a new project

```bash
wt init git@github.com:myorg/myapp.git
cd myapp/worktrees/main
```

### 2. Create a feature stack

```bash
# Start base feature (creates worktree but stays in current directory)
wt new auth-system
cd ~/myapp/worktrees/auth-system
gt create -am "feat: add authentication base"

# Or create and switch in one command
wt new auth-system --switch

# Build on top in same worktree
gt create -am "feat: add login endpoint"
gt submit --stack  # Creates 2 PRs

# Or create dependent feature in new worktree
wt new user-profiles --from auth-system
gt create -am "feat: add user profiles"
```

### 3. Work in parallel

```bash
# Terminal 1: Update auth system
cd ~/myapp/worktrees/auth-system
vim src/auth.js
gt modify -am "fix: correct token validation"

# Terminal 2: Work on profiles simultaneously
cd ~/myapp/worktrees/user-profiles
vim src/profiles.js
gt modify -am "feat: add profile pictures"

# Terminal 3: Quick bugfix
wt new fix-memory-leak
vim src/utils/cache.js
gt create -am "fix: prevent memory leak in cache"
```

### 4. Keep everything in sync

```bash
# Check if sync is needed (from within a worktree)
gt stack
# Shows stack status and parent relationships

# Sync entire stack (run in any worktree belonging to the stack)
gt stack rebase && gt submit --stack

# Sync all worktrees
wt sync-all
```

### 5. Navigate stacks efficiently

```bash
# You're in auth-system worktree
wt up     # Opens user-profiles in tmux
wt up     # Opens user-settings (if it exists)
wt down   # Back to user-profiles
wt bottom # Back to auth-system (stack base)

# No more confusion between branch and directory!
```

## Directory Structure

```
myproject/
├── .bare/              # Bare Git repository (space efficient)
├── worktrees/          # All worktrees (flat structure)
│   ├── main/           # Main branch worktree
│   ├── feature-1/      # Feature worktrees
│   └── .../
├── envs/               # Shared environment files
│   └── .env
└── .wt-config          # Repository configuration
```

## Repository Structure

### Repository Configuration (`.wt-config`)

Each worktree repository contains a `.wt-config` file at the root:

```bash
# Worktree repository configuration
REPO_NAME=myproject

# Default paths (uncomment to override)
# BARE_PATH=.bare
# WORKTREES_PATH=worktrees
# ENVS_PATH=envs

# Default branch detected from repository
DEFAULT_TRUNK=main
```

Most settings have sensible defaults and only need to be uncommented if you want to override them.

## Stack Management

wt integrates with Graphite stacks for managing dependent branches across worktrees:

```bash
# View stack info (from within a worktree)
$ gt stack
● feat/user-profiles (current)
  ├─ feat/auth-system
  └─ main

$ gt log --stack
# Shows all branches in stack

# Sync specific stack (run in any worktree belonging to the stack)
$ gt stack rebase && gt submit --stack
✓ Rebased auth-system onto main
✓ Rebased user-profiles onto auth-system
📤 Submitting stack...
✓ All PRs updated
```

### Detecting When Sync is Needed

Use Graphite's built-in commands to check sync status:

```bash
# Check current worktree stack status
$ gt stack
● feat/user-profiles (current)
  ├─ feat/auth-system ⚠ needs rebase
  └─ main

# Check what's changed
$ gt log --stack --behind
Shows commits that need rebasing

# Sync all worktrees with remote
$ wt sync-all
```

### Smart Stack Navigation

Navigate through your stack with automatic worktree switching:

```bash
# Traditional gt navigation (confusing with worktrees)
$ pwd
/myapp/worktrees/auth-system
$ gt up  # Goes to login-api branch
$ pwd
/myapp/worktrees/auth-system  # Still in wrong directory!

# wt navigation (switches both branch AND directory)
$ wt up
Switching to worktree: login-api
[Opens login-api/ in new tmux window]

$ wt down
Switching to worktree: auth-system
[Opens auth-system/ in new tmux window]

# Quick stack traversal
$ wt bottom  # Go to stack base
$ wt top     # Go to stack tip (coming soon)
```

## Advanced Features

### Multiple Base Branches

```bash
# Configure additional trunk
gt trunk --add release-v2

# Create worktree from different trunk
wt new hotfix --from release-v2 --trunk release-v2
```

### Batch Operations

```bash
# Run command in all worktrees
wt foreach 'npm install'

# Run in specific worktrees
wt foreach --match 'feature-*' 'npm test'

# Interactive selection
wt foreach -i 'gt submit'
```

## Working on a Single Branch

### Commit Strategy with Graphite

When working on a branch/PR, you have two main approaches:

#### Option 1: Single Commit with Amendments (Recommended)
```bash
# Initial work
gt create -am "feat: add user authentication"

# Continue working - amend the same commit
vim src/auth.js
gt modify -a  # or gt m -a

# More changes
vim tests/auth.test.js
gt modify -am "feat: add user authentication"  # Updates commit message if needed

# Submit to GitHub
gt submit
```

**Benefits:**
- Clean PR history (one commit = one logical change)
- Easier for reviewers
- Natural with Graphite's workflow
- No need to squash later

#### Option 2: Multiple Commits (When Appropriate)
```bash
# When multiple commits make sense:
# 1. Logically separate changes
gt create -m "feat: add auth database schema"
gt modify --commit -m "feat: add auth API endpoints"
gt modify --commit -m "test: add auth integration tests"

# 2. Work-in-progress commits (will squash later)
gt create -m "WIP: auth system"
gt modify --commit -m "WIP: add tests"
gt modify --commit -m "WIP: fix edge cases"

# Before submitting, squash into one
gt squash -m "feat: add complete auth system"
gt submit
```

**Use multiple commits when:**
- Changes are truly independent
- You want to preserve specific history
- Collaborating on the same branch
- Large refactoring with checkpoints

### Best Practice: Start with Single Commit

```bash
# Default to amending
gt create -am "feat: new feature"
# work work work...
gt modify -a  # Keep amending

# Only add commits when it makes sense
gt modify --commit -m "docs: update API documentation"  # Separate concern
```

This aligns with your current workflow of "save progress" commits but gives you cleaner PRs by default.

### Git Hooks Compatibility

Your existing Git hooks (including lefthook) continue to work with Graphite:

```bash
# Hooks run normally with these commands
gt create         # prepare-commit-msg hook runs
gt modify         # commit-msg hook runs
gt modify -c      # pre-commit hook runs

# Let your hook generate the message
gt create         # Opens editor, hook can modify message
gt modify -e      # Opens editor for amending

# Skip hooks when needed
gt create --no-verify -m "WIP: debugging"
```

**Note:** Graphite respects Git's `--verify` flag (enabled by default), so all your commit hooks work as expected.

## Best Practices

1. **One stack per major feature** - Keep related changes together
2. **Descriptive worktree names** - Use `feature-`, `fix-`, `experiment-` prefixes
3. **Regular cleanup** - Remove merged worktrees with `wt cleanup`
4. **Sync before context switch** - Always `gt sync` before switching tasks
5. **Use tmux/muxit integration** - Let `wt switch` manage your sessions
6. **Default to single commits** - Use `gt modify -a` unless multiple commits add value

## Troubleshooting

### Worktree in inconsistent state

```bash
# Repair worktree
wt repair <name>

# Force sync all worktrees with remote
wt sync-all --force --reset
```

### Stack relationships incorrect

```bash
# Rebuild stack metadata using Graphite
gt stack fix
```

### Disk space issues

```bash
# Show disk usage
wt disk-usage

# Clean up old worktrees
wt cleanup --older-than 30d
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
