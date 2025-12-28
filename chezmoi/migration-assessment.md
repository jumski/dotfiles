# Chezmoi Migration Assessment

## Current Workflow

**`make install` / `script/install`:**
1. Install pacman packages
2. Install AUR packages
3. Run `priority_install.sh` scripts (per-module)
4. Run `install.sh` scripts (per-module)
5. Run dotbot → creates symlinks from all `.dotbot/configs/*.yml`
6. Run `verify.sh` scripts

**Dotbot configs handle:**
- Symlink local files → `$HOME` (fish, nvim, tmux, git, etc.)
- Symlink **external paths** → SynologyDrive (aichat, aws creds, logseq, ssh)
- Glob patterns (`fish/functions/*.fish`, `kitty/*.conf`)
- Directory creation (`mkdir`)

## Migration Complexity

| Aspect | Difficulty | Notes |
|--------|------------|-------|
| Basic symlinks | Easy | `chezmoi add` handles these |
| Glob patterns | Easy | `chezmoi add` entire directories |
| External symlinks (SynologyDrive) | Medium | Need `.chezmoiexternal.toml` or symlink templates |
| Per-module `install.sh` | Medium | Convert to `run_once_*.sh` scripts |
| Package management | N/A | chezmoi doesn't do this - keep `script/install_*` |
| Verify scripts | Easy | Convert to `run_after_*.sh` |

## Verdict

**Migration effort**: Medium (2-4 hours for full conversion)

**Worth it?** Probably **no**, unless you need:
- Machine-specific templating
- Encrypted secrets in repo
- Multiple OS support

**Current setup is clean & modular.** Friction points:
- External SynologyDrive links require workarounds in chezmoi
- Lose "edit-in-place" workflow (symlinks → direct edits)
- Package scripts stay outside chezmoi anyway

**Recommendation**: Keep dotbot unless adding a second machine with different configs.
