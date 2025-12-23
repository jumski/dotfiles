# chezmoi vs My Dotfiles Setup

## What is chezmoi?

**chezmoi** is a declarative dotfiles manager that takes a different approach than symlink-based tools (like dotbot, which this repo uses).

### Core Concept

Instead of symlinking files from a repo into `$HOME`, chezmoi:
1. Maintains a **source directory** (Git-backed) as the "truth"
2. **Renders/templates** that source
3. **Writes real files** atomically into your home directory

## Key Features

| Feature | Description |
|---------|-------------|
| **Templating** | Go templates with variables for OS, hostname, architecture - vary configs per machine |
| **Secrets** | Built-in GPG/age encryption + password manager integration (Bitwarden, LastPass, etc.) |
| **Single binary** | Cross-platform, no runtime dependencies |
| **Atomic writes** | No half-written files; safe updates |
| **Dry-run/diff** | Preview changes before applying |

## Basic Workflow

```bash
chezmoi init <repo>       # bootstrap on new machine
chezmoi add ~/.zshrc      # track a file
chezmoi edit ~/.zshrc     # edit the source version
chezmoi diff              # see what would change
chezmoi apply             # sync home to match source
```

## Comparison: chezmoi vs dotbot

| Aspect | dotbot (current) | chezmoi |
|--------|------------------|---------|
| Mechanism | Symlinks via YAML config | Real files via templating |
| Per-machine logic | Custom shell scripts | Built-in templates |
| Secrets | External tooling | Native encryption/PM support |
| Complexity | Simple, lightweight | More features, steeper learning curve |
| File in $HOME | Symlinks pointing to repo | Actual files (copies) |

## When chezmoi shines

- **Multiple machines/OSes** with one repo and controlled variations
- **Public repo** but need to keep secrets encrypted or in password manager
- Want **one tool** instead of dotbot + custom scripts for variations
- Need **atomic updates** and easy dry-run previews

## When symlinks (dotbot/stow) are better

- **Edit-in-place workflow** - change `~/.config/fish/config.fish` directly and it's immediately in your repo. No `chezmoi edit` or `chezmoi apply` dance
- **Simpler mental model** - symlink points to repo file, what you see is what you get
- **Instant feedback** - `git status` in repo shows changes immediately after editing in $HOME
- **No build step** - no rendering, no apply, no potential drift between source and target
- **Debugging transparency** - `ls -la` shows exactly where a file comes from
- **Tools that modify configs** - apps that edit their own config files work naturally (changes go straight to repo)
- **Single machine** - if you only use one machine, templating overhead adds complexity without benefit
- **Lighter weight** - no binary to install, just symlinks and a simple YAML

### The key insight

Symlinks treat your repo as the **live filesystem**. Changes flow both directions naturally.

chezmoi treats your repo as a **build source**. Changes require explicit sync commands. This is powerful for templating but adds friction for simple edits.

## Tradeoffs for this setup

This repo uses dotbot + fish + fishtape with a clean modular structure:
- Each module is self-contained with its own `install.sh`
- Fish functions live in `functions/` directories
- Tests use fishtape with `*.test.fish` files

chezmoi would replace dotbot's symlink approach entirely. Considerations:

| Pro | Con |
|-----|-----|
| Built-in templating for multi-machine | Migration effort from current structure |
| Native secrets handling | Real files vs symlinks (can't edit in-place in repo) |
| Single binary, no Python dependency | Learning curve for Go template syntax |
| Atomic writes, safer updates | More complex mental model |

## Verdict

If the current setup works well and there's no complex multi-OS requirements or secrets management needs, dotbot remains simpler to maintain. chezmoi becomes compelling when:
- Managing dotfiles across significantly different machines (Linux/macOS/WSL)
- Needing to keep secrets in the repo securely
- Wanting machine-specific variations without branch gymnastics

## Resources

- [chezmoi.io](https://chezmoi.io) - Official documentation
- [Why use chezmoi?](https://chezmoi.io/why-use-chezmoi/) - Official comparison
- [What does chezmoi do?](https://chezmoi.io/what-does-chezmoi-do/) - Core concepts
