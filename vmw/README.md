# vmw - VM Worktree Manager

Run Claude Code with `--dangerously-skip-permissions` safely inside isolated KVM virtual machines.

## Quick Reference

```bash
# Setup (run once, requires sudo)
sudo ./vmw/install.sh

# Daily usage
vmw spawn /path/to/worktree    # Start VM for a worktree
vmw ssh <name>                 # SSH into VM (agent forwarding enabled)
vmw list                       # List all VMs
vmw stop <name>                # Graceful shutdown
vmw destroy <name>             # Force stop and remove VM
```

## Cheat Sheet

| Command | Description |
|---------|-------------|
| `vmw spawn <path>` | Create and start VM for worktree at `<path>` |
| `vmw ssh <name>` | SSH into VM with agent forwarding (`-A`) |
| `vmw list` | List all VMs (running and stopped) |
| `vmw stop <name>` | Graceful shutdown (ACPI) |
| `vmw destroy <name>` | Force stop and undefine VM |

**VM naming**: The VM name is derived from the last directory component of the path.
- `/home/user/project/worktrees/feature-x` → VM name: `feature-x`

**Accessing VMs**: After spawning, wait ~60-90 seconds for cloud-init to complete, then:
```bash
vmw ssh feature-x
# or
ssh -A claude@feature-x.local
```

---

## Overview

vmw creates lightweight KVM virtual machines for running Claude Code in a sandboxed environment. Each VM:

- Is a linked clone of a Debian 12 golden image (~450MB base)
- Has your worktree mounted at `/home/claude/repo` via virtiofs
- Has API keys mounted at `/home/claude/.secrets` (read-only)
- Comes with Node.js 24 and Claude Code pre-installed
- Is accessible via mDNS (`<vm-name>.local`)

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Host                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │  Worktree   │    │  Secrets    │    │   Bridge    │ │
│  │ /path/to/wt │    │ ~/.config/  │    │    br0      │ │
│  │             │    │ vmw/secrets │    │             │ │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘ │
│         │virtiofs         │virtiofs          │         │
│  ┌──────┴─────────────────┴──────────────────┴───────┐ │
│  │                     KVM VM                        │ │
│  │  /home/claude/repo     /home/claude/.secrets      │ │
│  │       (rw)                   (ro)                 │ │
│  │                                                   │ │
│  │  claude@<vm-name>.local                           │ │
│  │  - Node.js 24                                     │ │
│  │  - Claude Code (npm global)                       │ │
│  │  - API keys auto-loaded from .secrets/secrets.env │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Security Model

| Component | Host | VM |
|-----------|------|-----|
| Worktree files | Full access | Read/write via virtiofs |
| API keys | `~/.config/vmw/secrets.env` | Read-only mount |
| Network | Bridge (br0) | Same L2 network, mDNS enabled |
| SSH | Your key injected | claude user, passwordless sudo |

If a VM is compromised, revoke the API keys in `secrets.env` without affecting your host keys.

---

## Installation

### Prerequisites

Install required packages (Arch/Manjaro):
```bash
yay -S libvirt qemu-full virtiofsd cdrtools nss-mdns avahi
```

### Setup

```bash
sudo ./vmw/install.sh
```

The installer (idempotent, safe to re-run):
1. Loads KVM kernel modules
2. Enables libvirtd and avahi-daemon services
3. Adds your user to the `libvirt` group
4. Creates a network bridge `br0` for mDNS
5. Downloads Debian 12 cloud image as golden image
6. Creates `~/.config/vmw/secrets.env` template

**After installation**, log out and back in for group membership to take effect.

### Configure API Keys

Edit `~/.config/vmw/secrets.env`:
```bash
ANTHROPIC_API_KEY=sk-ant-xxx
# Optional:
PERPLEXITY_API_KEY=pplx-xxx
OPENAI_API_KEY=sk-xxx
```

These are automatically sourced when you SSH into a VM.

---

## Usage

### Starting a VM

```bash
vmw spawn ~/Code/myproject/worktrees/feature-branch
```

This:
1. Creates a linked clone disk from the golden image
2. Generates cloud-init configuration with your SSH key
3. Starts virtiofsd for worktree and secrets mounts
4. Defines and starts the VM

Wait ~60-90 seconds for cloud-init to install packages and configure mDNS.

### Connecting

```bash
vmw ssh feature-branch
```

Or directly:
```bash
ssh -A claude@feature-branch.local
```

SSH agent forwarding (`-A`) is enabled, so your git credentials work inside the VM.

### Inside the VM

```bash
cd ~/repo                    # Your worktree is here
claude --dangerously-skip-permissions
```

API keys are automatically loaded from `~/.secrets/secrets.env`.

### Stopping VMs

```bash
vmw stop feature-branch      # Graceful ACPI shutdown
vmw destroy feature-branch   # Force stop and remove
```

### Listing VMs

```bash
vmw list
```

---

## Configuration

### Directory Structure

```
~/.config/vmw/
├── golden-image.qcow2       # Debian 12 base image (~450MB)
├── secrets.env              # API keys (mounted read-only in VMs)
└── instances/
    └── <vm-name>/
        ├── disk.qcow2       # Linked clone (copy-on-write)
        ├── cloud-init.iso   # cloud-init configuration
        ├── domain.xml       # libvirt domain definition
        └── cloud-init/      # Generated cloud-init files
```

### VM Specifications

| Resource | Value |
|----------|-------|
| Memory | 4 GB |
| vCPUs | 4 |
| Disk | 20 GB (thin provisioned) |
| Network | Bridged (br0) |
| Base OS | Debian 12 (Bookworm) |

### Pre-installed in VMs

- Node.js 24 (via nodesource)
- Claude Code (`@anthropic-ai/claude-code`)
- avahi-daemon (mDNS)
- git, curl, build-essential

---

## Troubleshooting

### VM has no IP / mDNS not working

1. Check if br0 bridge is active:
   ```bash
   ip addr show br0
   ```

2. If not, activate it:
   ```bash
   nmcli connection up br0-slave-<your-interface>
   ```

3. Verify avahi sees the VM:
   ```bash
   avahi-browse -at | grep <vm-name>
   ```

### SSH connection refused

Cloud-init takes ~60-90 seconds. Check VM status:
```bash
virsh domifaddr <vm-name> --source arp
```

### Virtiofs warnings

The virtiofsd warnings about file handles and sandbox are expected when running as non-root. They don't affect functionality.

### Permission denied on worktree

Ensure the worktree path is accessible. Virtiofs runs as your user, so standard file permissions apply.

---

## How It Works

### Golden Image

A Debian 12 cloud image is downloaded once and used as a backing file for all VMs. Each VM gets a linked clone (copy-on-write), so only changes are stored per-VM.

### Cloud-Init

On first boot, cloud-init:
1. Sets the hostname
2. Creates the `claude` user with your SSH key
3. Installs packages (avahi-daemon, Node.js, etc.)
4. Mounts virtiofs shares
5. Installs Claude Code globally

### Virtiofs

Two virtiofsd instances run per VM:
- **repo**: Mounts your worktree at `/home/claude/repo` (read-write)
- **secrets**: Mounts `~/.config/vmw/` at `/home/claude/.secrets` (read-only)

### Networking

VMs connect to a bridge (`br0`) that includes your physical NIC. This puts VMs on the same L2 network as your host, enabling mDNS resolution (`<vm-name>.local`).
