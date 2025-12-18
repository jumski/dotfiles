# Manjaro Recovery Gist - laptop

Generated: 2025-12-17 16:31
Kernel: 6.12.12-2-MANJARO

## System Layout

| Component | Device/Value |
|-----------|--------------|
| LUKS Partition | `/dev/sda1` |
| Mapper Name | `luks-4d1b956a-ebd7-4d20-a90e-038623582f57` |
| BTRFS Device | `/dev/mapper/luks-4d1b956a-ebd7-4d20-a90e-038623582f57` |
| EFI Partition | `/dev/nvme0n1p1` |
| EFI Mount | `/boot/efi` |
| Root Subvolume | `/@` |

---

## Pre-Reboot: Safe Upgrade Procedure

Run this as a single chain (stops on first error):

```bash
sudo pacman -Syu && \
sudo mkinitcpio -P && \
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro && \
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

After upgrade completes successfully:

```bash
# Create safety snapshot
sudo timeshift --create --comments "post-upgrade-$(date +%Y%m%d)"

# Regenerate GRUB to include snapshot
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Only now reboot
sudo reboot
```

---

## Recovery from Live USB

### Step 1: Boot Manjaro Live USB

Select "Boot with open source drivers" or similar.

### Step 2: Open terminal and become root

```bash
sudo -i
```

### Step 3: Decrypt LUKS partition

```bash
cryptsetup open /dev/sda1 luks-4d1b956a-ebd7-4d20-a90e-038623582f57
```

Enter your LUKS passphrase when prompted.

### Step 4: Mount BTRFS root

```bash
mount -o subvol=/@ /dev/mapper/luks-4d1b956a-ebd7-4d20-a90e-038623582f57 /mnt
```

### Step 5: Mount EFI partition

```bash
mount /dev/nvme0n1p1 /mnt/boot/efi
```

### Step 6: Chroot into system

```bash
manjaro-chroot /mnt
```

You are now inside your installed system.

---

## Inside Chroot: Fix GRUB

### Option A: Reinstall GRUB (most common fix)

```bash
# Regenerate initramfs
mkinitcpio -P

# Reinstall GRUB to EFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro

# Regenerate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```

### Option B: Restore from Timeshift snapshot

```bash
# List available snapshots
timeshift --list

# Restore specific snapshot (replace with actual snapshot name)
timeshift --restore --snapshot '2024-12-15_10-30-00'
```

### Option C: Downgrade problematic package

```bash
# Find cached packages
ls /var/cache/pacman/pkg/ | grep <package-name>

# Downgrade
pacman -U /var/cache/pacman/pkg/<package-old-version>.pkg.tar.zst
```

---

## Exit and Reboot

```bash
# Exit chroot
exit

# Unmount everything
umount -R /mnt

# Close LUKS
cryptsetup close luks-4d1b956a-ebd7-4d20-a90e-038623582f57

# Reboot (remove USB first)
reboot
```

---

## Troubleshooting

### "error: no such device" in GRUB

GRUB can't find the encrypted partition. Fix:

```bash
# Inside chroot, ensure cryptdevice is in GRUB config
grep -i cryptdevice /etc/default/grub

# Should contain something like:
# GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda1:luks-4d1b956a-ebd7-4d20-a90e-038623582f57"

# If missing, add it and regenerate:
grub-mkconfig -o /boot/grub/grub.cfg
```

### GRUB menu doesn't appear

```bash
# Edit GRUB defaults
nano /etc/default/grub

# Set these values:
# GRUB_TIMEOUT=5
# GRUB_TIMEOUT_STYLE=menu

# Regenerate
grub-mkconfig -o /boot/grub/grub.cfg
```

### Snapshots not appearing in GRUB

```bash
# Check grub-btrfsd service
systemctl status grub-btrfsd

# Restart it
systemctl restart grub-btrfsd

# Manually regenerate
grub-mkconfig -o /boot/grub/grub.cfg
```

### initramfs missing encrypt hook

```bash
# Check mkinitcpio config
grep HOOKS /etc/mkinitcpio.conf

# Should include: encrypt
# Example: HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)

# If missing, edit and add 'encrypt' before 'filesystems'
nano /etc/mkinitcpio.conf

# Regenerate
mkinitcpio -P
```

### Can't mount - wrong subvolume

```bash
# List all subvolumes
mount /dev/mapper/luks-4d1b956a-ebd7-4d20-a90e-038623582f57 /mnt
btrfs subvolume list /mnt

# Find your root subvolume (usually @ or @root)
# Unmount and remount with correct subvol
umount /mnt
mount -o subvol=@ /dev/mapper/luks-4d1b956a-ebd7-4d20-a90e-038623582f57 /mnt
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Open LUKS | `cryptsetup open /dev/sda1 luks-4d1b956a-ebd7-4d20-a90e-038623582f57` |
| Mount root | `mount -o subvol=/@ /dev/mapper/luks-4d1b956a-ebd7-4d20-a90e-038623582f57 /mnt` |
| Mount EFI | `mount /dev/nvme0n1p1 /mnt/boot/efi` |
| Chroot | `manjaro-chroot /mnt` |
| Fix GRUB | `mkinitcpio -P && grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro && grub-mkconfig -o /boot/grub/grub.cfg` |
| Exit | `exit && umount -R /mnt && cryptsetup close luks-4d1b956a-ebd7-4d20-a90e-038623582f57` |

---

*Keep this file on your phone or another device accessible during recovery.*
