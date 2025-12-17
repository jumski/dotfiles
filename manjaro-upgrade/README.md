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

```bash
./manjaro-upgrade/install.sh
```

Then open Timeshift GUI and:
1. Select **BTRFS** snapshot type
2. Choose snapshot location (your root BTRFS partition)
3. Enable **weekly** scheduled snapshots
4. Create your first snapshot manually

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

1. **Read release notes** at https://forum.manjaro.org/c/announcements/stable-updates
2. Create manual snapshot:
   ```bash
   sudo timeshift --create --comments "Before YYYY-MM-DD update"
   ```
3. Run upgrade:
   ```bash
   sudo pacman -Syu
   ```

Note: `timeshift-autosnap-manjaro` also creates snapshots automatically on every upgrade.

### After Update

1. Reboot and verify system works
2. If broken, see Recovery section below

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

## Timeshift Configuration

Config file: `/etc/timeshift-autosnap.conf`

```ini
# Skip autosnap for specific operations
# SKIP_AUTOSNAP=1 pamac upgrade -a

# Number of autosnap snapshots to keep
maxSnapshots=3
```

## Troubleshooting

### Snapshots not appearing in GRUB

```bash
# Check grub-btrfsd service
systemctl status grub-btrfsd

# Manually regenerate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Timeshift not creating BTRFS snapshots

Verify subvolume setup:
```bash
sudo btrfs subvolume list /
```

Should show `@` and `@home` subvolumes.

## Disk Space

BTRFS snapshots are copy-on-write - they only store **differences**.
- First snapshot: ~0 bytes (just metadata)
- Subsequent snapshots: only changed blocks

Safe to keep 3-5 snapshots without significant space impact.

## Related Resources

- [Manjaro Forum - Stable Updates](https://forum.manjaro.org/c/announcements/stable-updates)
- [Timeshift Documentation](https://github.com/linuxmint/timeshift)
- [grub-btrfs GitHub](https://github.com/Antynea/grub-btrfs)
