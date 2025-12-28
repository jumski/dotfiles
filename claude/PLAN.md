# Migration Plan: ~/.claude Direct Version Control

## Background

Current setup uses dotbot symlinks from `~/.claude/*` to `~/.dotfiles/claude/*`.
This causes issues with Claude Code's symlink resolution:
- Skills not discovered (#14836)
- Commands not discovered (#13453)
- Permission path mismatches

## Strategy

Convert `~/.claude/` to a directly version-controlled directory, either as:
- **Option A**: Git submodule of dotfiles repo
- **Option B**: Standalone git repo

## Files Classification

### Track in Git
```
settings.json          # permissions, hooks, plugins
commands/              # custom slash commands
skills/                # custom skills
CLAUDE.md              # global context (currently empty)
hooks/                 # hook scripts (from dotfiles)
statusline.sh          # status line script
file-suggestion.sh     # file suggestion script
```

### Ignore (secrets/transient)
```
.credentials.json      # API credentials
history.jsonl          # conversation history
stats-cache.json       # usage stats
debug/                 # debug logs
file-history/          # file edit history
session-env/           # session environment snapshots
shell-snapshots/       # shell state snapshots
plans/                 # agent plans
projects/              # project-specific data
todos/                 # todo lists
local/                 # local overrides
chrome/                # browser extension data
ide/                   # IDE extension data
plugins/               # installed plugins (auto-managed)
statsig/               # feature flags
telemetry/             # telemetry data
```

## Migration Steps

### Phase 1: Prepare

1. **Backup current state**
   ```bash
   cp -rL ~/.claude ~/.claude.backup
   ```

2. **Create .gitignore in dotfiles**
   ```bash
   cat > ~/.dotfiles/claude/.gitignore << 'EOF'
   # Secrets
   .credentials.json

   # History & State
   history.jsonl
   stats-cache.json

   # Transient directories
   debug/
   file-history/
   session-env/
   shell-snapshots/
   plans/
   projects/
   todos/
   local/

   # Auto-managed
   chrome/
   ide/
   plugins/
   statsig/
   telemetry/
   EOF
   ```

### Phase 2: Restructure Dotfiles

3. **Move tracked files to dotfiles claude/**
   ```bash
   # Already have: settings.json, commands/, skills/
   # Copy additional files we want to track:
   cp ~/.claude/CLAUDE.md ~/.dotfiles/claude/
   # hooks/ already exists in dotfiles
   # statusline.sh already exists in dotfiles
   # file-suggestion.sh already exists in dotfiles
   ```

### Phase 3: Convert ~/.claude to Git Repo

4. **Remove symlinks and copy real files**
   ```bash
   cd ~/.claude

   # Remove symlinks
   rm commands skills settings.json file-suggestion.sh

   # Copy from dotfiles
   cp ~/.dotfiles/claude/settings.json .
   cp -r ~/.dotfiles/claude/commands .
   cp -r ~/.dotfiles/claude/skills .
   cp ~/.dotfiles/claude/file-suggestion.sh .
   cp ~/.dotfiles/claude/statusline.sh .
   cp -r ~/.dotfiles/claude/hooks .
   cp ~/.dotfiles/claude/.gitignore .
   ```

5. **Initialize git in ~/.claude**
   ```bash
   cd ~/.claude
   git init
   git add .gitignore settings.json commands/ skills/ CLAUDE.md
   git add hooks/ statusline.sh file-suggestion.sh
   git commit -m "Initial ~/.claude version control"
   ```

### Phase 4: Link to Dotfiles (Choose One)

#### Option A: Git Submodule
```bash
cd ~/.dotfiles
# Remove old claude config from dotbot
# Add ~/.claude as submodule pointing to new repo
git submodule add <repo-url> claude-home
```

#### Option B: Separate Repo with Remote
```bash
cd ~/.claude
git remote add origin <your-repo-url>
git push -u origin main
```

#### Option C: Bare Repo in Dotfiles (Advanced)
```bash
# Use ~/.dotfiles/claude-home.git as bare repo
# Work tree at ~/.claude
git init --bare ~/.dotfiles/claude-home.git
alias claude-git='git --git-dir=$HOME/.dotfiles/claude-home.git --work-tree=$HOME/.claude'
claude-git add .
claude-git commit -m "Initial commit"
```

### Phase 5: Update Dotbot Config

6. **Remove claude symlinks from dotbot**
   ```yaml
   # Remove these from .dotbot/configs/claude.yml:
   # - link:
   #     ~/.claude/commands: claude/commands
   #     ~/.claude/settings.json: claude/settings.json
   #     ~/.claude/file-suggestion.sh: claude/file-suggestion.sh
   #     ~/.claude/skills: claude/skills
   ```

7. **Add clone/pull step instead**
   ```yaml
   # In .dotbot/configs/claude.yml or install.sh:
   - shell:
       - description: Clone ~/.claude repo
         command: |
           if [ ! -d ~/.claude/.git ]; then
             git clone <repo-url> ~/.claude
           else
             git -C ~/.claude pull
           fi
   ```

### Phase 6: Verify

8. **Test Claude Code**
   ```bash
   claude --version
   # Check /skills works
   # Check /commands works
   # Check permissions are respected
   ```

## Rollback Plan

If issues occur:
```bash
rm -rf ~/.claude
mv ~/.claude.backup ~/.claude
cd ~/.dotfiles && dotbot -c install.conf.yaml
```

## Multi-Machine Sync

For new machines:
```bash
git clone <claude-repo> ~/.claude
```

For syncing changes:
```bash
cd ~/.claude
git pull  # or git push after local changes
```

## Machine-Specific Settings

Use `settings.local.json` (if supported by Claude Code) for machine-specific overrides:
```json
{
  "permissions": {
    "allow": ["machine-specific-permission"]
  }
}
```

Add to .gitignore:
```
settings.local.json
```

## Notes

- Keep `~/.dotfiles/claude/` for reference/archive or remove after migration
- The statusline.sh in ~/.claude should use absolute paths
- hooks/ scripts should also use absolute paths or be self-contained
