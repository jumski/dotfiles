# Claude Directory Mounting in VMW

Selective mounting of `~/.claude/` into VMW virtual machines.

## Goal

Mount specific files/directories from host's `~/.claude/` into VMs as read-only at `/home/claude/.claude/`, while excluding local state (projects, sessions, todos, memory) that wouldn't work due to different folder structures.

## Architecture

```
Host                              VM
~/.claude/                        /home/claude/.claude/
├── .credentials.json ──────────► ├── .credentials.json (ro)
├── CLAUDE.md ──────────────────► ├── CLAUDE.md (ro)
├── settings.json ──────────────► ├── settings.json (ro)
├── file-suggestion.sh ─────────► ├── file-suggestion.sh (ro)
├── statusline.sh ──────────────► ├── statusline.sh (ro)
├── skills/ ────────────────────► ├── skills/ (ro)
├── commands/ ──────────────────► ├── commands/ (ro)
├── projects/        (NOT MOUNTED - local state)
├── sessions/        (NOT MOUNTED - local state)
├── todos/           (NOT MOUNTED - local state)
└── memory/          (NOT MOUNTED - local state)
```

## Implementation

### Files Created

| File | Purpose |
|------|---------|
| `vmw/claude-mount.list` | Config listing paths to mount (editable) |
| `vmw/functions/_vmw_stage_claude.fish` | Helper to create staging dir with symlinks |

### Files To Modify

| File | Changes |
|------|---------|
| `vmw/functions/vmw_spawn.fish` | Add staging + virtiofsd for claude mount |
| `vmw/templates/domain.xml.template` | Add `<filesystem>` entry for claude |
| `vmw/templates/cloud-init/user-data.template` | Add mount point, fstab, systemd unit |

## Detailed Changes

### 1. vmw/claude-mount.list (DONE)

Config file listing what to mount from `~/.claude/`:

```
# One path per line, relative to ~/.claude/
.credentials.json
CLAUDE.md
settings.json
file-suggestion.sh
statusline.sh
skills
commands
```

### 2. vmw/functions/_vmw_stage_claude.fish (DONE)

Helper function that:
- Reads `claude-mount.list`
- Creates staging directory at `$instance_dir/claude-staging/`
- Creates symlinks to listed items (virtiofsd follows symlinks)

### 3. vmw/functions/vmw_spawn.fish (TODO)

Add after line 93 (after cloud-init ISO creation):

```fish
# Stage claude directory for mounting
echo "Staging ~/.claude/ for mount..."
set -l claude_staging_dir $instance_dir/claude-staging
rm -rf $claude_staging_dir
_vmw_stage_claude $claude_staging_dir
if test $status -ne 0
    echo "Error: Failed to stage claude directory" >&2
    return 1
end
```

Add to socket variables (around line 98):
```fish
set -l claude_socket $instance_dir/virtiofsd-claude.sock
```

Add to pkill section:
```fish
pkill -f "virtiofsd.*$claude_socket" 2>/dev/null
```

Add after secrets virtiofsd start (around line 115):
```fish
# Start virtiofsd for claude (read-only enforced at mount level)
$virtiofsd_bin --socket-path=$claude_socket \
    --shared-dir=$claude_staging_dir \
    --cache=auto &
set -l claude_pid $last_pid
```

Add to sed substitution (around line 130):
```fish
-e "s|{{VIRTIOFS_CLAUDE_SOCKET}}|$claude_socket|g" \
```

### 4. vmw/templates/domain.xml.template (TODO)

Add after secrets filesystem entry (after line 53):

```xml
<!-- Virtiofs: claude config mount (ro enforced in cloud-init) -->
<filesystem type='mount' accessmode='passthrough'>
  <driver type='virtiofs'/>
  <source socket='{{VIRTIOFS_CLAUDE_SOCKET}}'/>
  <target dir='claude'/>
</filesystem>
```

### 5. vmw/templates/cloud-init/user-data.template (TODO)

Add to mkdir section (after line 30):
```yaml
- mkdir -p /home/claude/.claude
```

Update chown (line 31):
```yaml
- chown claude:claude /home/claude/repo /home/claude/.secrets /home/claude/.claude
```

Add mount command (after line 35):
```yaml
- mount -t virtiofs claude /home/claude/.claude -o ro
```

Add fstab entry (after line 39):
```yaml
- echo 'claude /home/claude/.claude virtiofs ro 0 0' >> /etc/fstab
```

Add systemd mount unit in write_files section (after line 80):
```yaml
- path: /etc/systemd/system/virtiofs-claude.mount
  content: |
    [Unit]
    Description=Mount virtiofs claude config share
    After=local-fs.target

    [Mount]
    What=claude
    Where=/home/claude/.claude
    Type=virtiofs
    Options=ro

    [Install]
    WantedBy=multi-user.target
```

## Progress

- [x] Create `vmw/claude-mount.list`
- [x] Create `vmw/functions/_vmw_stage_claude.fish`
- [ ] Update `vmw/functions/vmw_spawn.fish`
- [ ] Update `vmw/templates/domain.xml.template`
- [ ] Update `vmw/templates/cloud-init/user-data.template`
- [ ] Test with a VM

## Future Considerations

- Add support for rw mounts if needed (extend config format)
- Consider mounting entire `~/.claude/` and using overlayfs for local state
- Add validation that listed paths exist before VM spawn
