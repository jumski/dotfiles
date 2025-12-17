# Manjaro Safe Upgrade System

Automatic BTRFS snapshots before every system upgrade with bootable recovery.

## What This Does

1. **timeshift-autosnap-manjaro** - Creates snapshot before every `pacman -Syu`
2. **grub-btrfs** - Adds snapshots to GRUB menu for bootable recovery
3. **cronie** - Enables scheduled snapshot automation

## Prerequisites

- BTRFS root filesystem (this dotfiles setup uses BTRFS + LUKS)
- Manjaro Linux

## Installation

### Step 1: Run install script

```bash
./manjaro-upgrade/install.sh
```

This installs packages and configures services.

### Step 2: Configure Timeshift (REQUIRED)

Open Timeshift GUI and configure:

1. **Snapshot Type:** Select **BTRFS**
2. **Snapshot Location:** Select your root BTRFS partition
3. **Include @home:** Check "Include @home subvolume in backups"
4. **Schedule** (maximum protection):

| Schedule | Keep |
|----------|------|
| Boot     | 3    |
| Daily    | 7    |
| Weekly   | 4    |

5. **Create first snapshot** - Click "Create" button

### Step 3: Verify setup

```bash
./manjaro-upgrade/verify.sh
```

This runs automatically at end of `script/install` and will fail loudly if Timeshift isn't configured.

## Safe Upgrade Procedure

### Quick Way (Recommended)

```bash
safe-upgrade
```

This script:
1. Checks for available updates
2. Shows what will be upgraded
3. Creates a named snapshot before upgrading
4. Runs `pacman -Syu`
5. Shows recovery instructions

### Manual Way

```bash
sudo pacman -Syu
```

Note: `timeshift-autosnap-manjaro` creates snapshots automatically on every upgrade.

## Recovery Procedures

### Option 1: Boot from Snapshot (Easiest)

If system boots to GRUB:

1. In GRUB menu, select **"Manjaro Linux snapshots"**
2. Choose the snapshot from before the broken update
3. System boots into that snapshot state
4. Once booted, open Timeshift and **Restore** that snapshot to make it permanent

### Option 2: Restore from Live USB

If GRUB itself is broken:

```bash
# 1. Boot Manjaro Live USB

# 2. Open encrypted partition (find your partition with lsblk)
sudo cryptsetup open /dev/nvme0n1p2 crypt

# 3. Mount the BTRFS root
sudo mount -o subvol=@ /dev/mapper/crypt /mnt

# 4. Mount EFI partition
sudo mkdir -p /mnt/boot/efi
sudo mount /dev/nvme0n1p1 /mnt/boot/efi

# 5. Chroot into system
sudo manjaro-chroot /mnt

# 6. Fix GRUB
install-grub

# 7. Exit and reboot
exit
sudo umount -R /mnt
sudo reboot
```

### Option 3: Rollback via Timeshift CLI

From Live USB after mounting (steps 1-5 above):

```bash
# List available snapshots
sudo timeshift --list

# Restore specific snapshot
sudo timeshift --restore --snapshot '2024-12-15_10-30-00'
```

## Snapshot Types Summary

| Type | Trigger | Purpose |
|------|---------|---------|
| Boot | Every boot | Catches issues after reboot |
| Daily | Once per day | Week of rollback points |
| Weekly | Once per week | Month of history |
| Autosnap | Before `pacman -Syu` | Pre-upgrade safety net |
| Manual | `safe-upgrade` script | Named, explicit backup |

## Disk Space

BTRFS snapshots are copy-on-write - they only store **differences**.
- First snapshot: ~0 bytes (just metadata)
- Subsequent snapshots: only changed blocks
- Typical usage: 5-20GB for all snapshots combined

## Troubleshooting

### Snapshots not appearing in GRUB

```bash
# Check grub-btrfsd service
systemctl status grub-btrfsd

# Manually regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Verification fails

Run `./manjaro-upgrade/verify.sh` to see what's missing, then configure Timeshift accordingly.

## Related Resources

- [Manjaro Forum - Stable Updates](https://forum.manjaro.org/c/announcements/stable-updates)
- [Timeshift Documentation](https://github.com/linuxmint/timeshift)
- [grub-btrfs GitHub](https://github.com/Antynea/grub-btrfs)
