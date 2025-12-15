---
name: nas
description: Use when user asks to "check NAS", "inspect containers on NAS", "run command on NAS", "check docker on NAS", or any task requiring NAS server access. Provides access patterns and directory structure for the Synology NAS.
---

# NAS Access Skill

Access the user's Synology NAS for Docker container management, file inspection, and remote commands.

<critical>
NEVER use `ssh nas` directly. ALWAYS use the `nas-ssh` wrapper script.
</critical>

## Access Method

```bash
/home/jumski/Code/jumski/dockge-stacks/bin/nas-ssh <command>
```

**Examples:**
```bash
nas-ssh ls /volume2/docker/stacks
nas-ssh docker ps
nas-ssh docker logs <container>
```

## Important Directories

### Docker Stacks (`/volume2/docker/stacks`)
Git clone of `dockge-stacks` repo. Contains Docker Compose stacks:
- `caddy` - Reverse proxy
- `family-dashboard` - Custom dashboard
- `getcore` - Getcore service
- `homeassistant` - Home Assistant stack (split compose files)
- `kopia-backup` - Backup service
- `media` - Jellyfin, qBittorrent, *arr apps
- `meta` - Monitoring (Uptime Kuma)
- `netbird` - VPN peer
- `windmill` - Automation platform

### Home Assistant Config (`/volume2/docker/homeassistant/config`)
Git clone of `homeassistant-config` repo. Contains:
- `configuration.yaml` - Main HA config
- `automations.yaml` - Automations
- `scripts.yaml` - Scripts
- `esphome/` - ESPHome device configs
- `custom_components/` - HACS integrations
- `www/` - Static assets

## Common Operations

**List running containers:**
```bash
nas-ssh docker ps
```

**View container logs:**
```bash
nas-ssh docker logs --tail 100 <container>
```

**Check container status:**
```bash
nas-ssh docker inspect <container>
```

**Restart a container:**
```bash
nas-ssh docker restart <container>
```

**View stack compose file:**
```bash
nas-ssh cat /volume2/docker/stacks/<stack>/compose.yaml
```

## Guidelines

- **Prefer read operations** - Inspect before modifying
- **Use full paths** - Always use absolute paths on NAS
- **Check before restart** - Verify container state before restarting services
