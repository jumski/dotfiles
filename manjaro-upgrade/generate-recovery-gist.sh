#!/bin/bash
# Generate personalized recovery gist for Manjaro LUKS+BTRFS system
# Run this BEFORE upgrading, upload the output somewhere accessible

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="${SCRIPT_DIR}/$(hostname)-upgrade-recovery.md"

# Gather system info
echo "Gathering system information..."

EFI_PART=$(findmnt /boot/efi -n -o SOURCE 2>/dev/null || findmnt /efi -n -o SOURCE 2>/dev/null || echo "NOT_FOUND")
EFI_MOUNT=$(findmnt /boot/efi -n -o TARGET 2>/dev/null || findmnt /efi -n -o TARGET 2>/dev/null || echo "/boot/efi")
LUKS_DEVICE=$(lsblk -o NAME,FSTYPE -r | grep crypto_LUKS | head -1 | awk '{print $1}')
LUKS_PATH="/dev/${LUKS_DEVICE}"
MAPPER_NAME=$(lsblk -o NAME,TYPE -r | grep crypt | head -1 | awk '{print $1}')
BTRFS_DEVICE="/dev/mapper/${MAPPER_NAME}"
ROOT_SUBVOL=$(findmnt / -n -o OPTIONS | grep -oP 'subvol=\K[^,]+' || echo "@")
HOSTNAME=$(hostname)
DATE=$(date '+%Y-%m-%d %H:%M')
KERNEL=$(uname -r)

# Verify we found the devices
if [[ -z "$LUKS_DEVICE" ]]; then
    echo "WARNING: Could not detect LUKS device. Check lsblk output."
    LUKS_PATH="/dev/nvme0n1p2  # VERIFY THIS"
fi

if [[ -z "$MAPPER_NAME" ]]; then
    MAPPER_NAME="crypt"
    BTRFS_DEVICE="/dev/mapper/crypt  # VERIFY THIS"
fi

cat > "$OUTPUT" << EOF
# Manjaro Recovery Gist - ${HOSTNAME}

Generated: ${DATE}
Kernel: ${KERNEL}

## System Layout

| Component | Device/Value |
|-----------|--------------|
| LUKS Partition | \`${LUKS_PATH}\` |
| Mapper Name | \`${MAPPER_NAME}\` |
| BTRFS Device | \`${BTRFS_DEVICE}\` |
| EFI Partition | \`${EFI_PART}\` |
| EFI Mount | \`${EFI_MOUNT}\` |
| Root Subvolume | \`${ROOT_SUBVOL}\` |

---

## Pre-Reboot: Safe Upgrade Procedure

Run this as a single chain (stops on first error):

\`\`\`bash
sudo pacman -Syu && \\
sudo mkinitcpio -P && \\
sudo grub-install --target=x86_64-efi --efi-directory=${EFI_MOUNT} --bootloader-id=manjaro && \\
sudo grub-mkconfig -o /boot/grub/grub.cfg
\`\`\`

After upgrade completes successfully:

\`\`\`bash
# Create safety snapshot
sudo timeshift --create --comments "post-upgrade-\$(date +%Y%m%d)"

# Regenerate GRUB to include snapshot
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Only now reboot
sudo reboot
\`\`\`

---

## Recovery from Live USB

### Step 1: Boot Manjaro Live USB

Select "Boot with open source drivers" or similar.

### Step 2: Open terminal and become root

\`\`\`bash
sudo -i
\`\`\`

### Step 3: Decrypt LUKS partition

\`\`\`bash
cryptsetup open ${LUKS_PATH} ${MAPPER_NAME}
\`\`\`

Enter your LUKS passphrase when prompted.

### Step 4: Mount BTRFS root

\`\`\`bash
mount -o subvol=${ROOT_SUBVOL} ${BTRFS_DEVICE} /mnt
\`\`\`

### Step 5: Mount EFI partition

\`\`\`bash
mount ${EFI_PART} /mnt${EFI_MOUNT}
\`\`\`

### Step 6: Chroot into system

\`\`\`bash
manjaro-chroot /mnt
\`\`\`

You are now inside your installed system.

---

## Inside Chroot: Fix GRUB

### Option A: Reinstall GRUB (most common fix)

\`\`\`bash
# Regenerate initramfs
mkinitcpio -P

# Reinstall GRUB to EFI
grub-install --target=x86_64-efi --efi-directory=${EFI_MOUNT} --bootloader-id=manjaro

# Regenerate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
\`\`\`

### Option B: Restore from Timeshift snapshot

\`\`\`bash
# List available snapshots
timeshift --list

# Restore specific snapshot (replace with actual snapshot name)
timeshift --restore --snapshot '2024-12-15_10-30-00'
\`\`\`

### Option C: Downgrade problematic package

\`\`\`bash
# Find cached packages
ls /var/cache/pacman/pkg/ | grep <package-name>

# Downgrade
pacman -U /var/cache/pacman/pkg/<package-old-version>.pkg.tar.zst
\`\`\`

---

## Exit and Reboot

\`\`\`bash
# Exit chroot
exit

# Unmount everything
umount -R /mnt

# Close LUKS
cryptsetup close ${MAPPER_NAME}

# Reboot (remove USB first)
reboot
\`\`\`

---

## Troubleshooting

### "error: no such device" in GRUB

GRUB can't find the encrypted partition. Fix:

\`\`\`bash
# Inside chroot, ensure cryptdevice is in GRUB config
grep -i cryptdevice /etc/default/grub

# Should contain something like:
# GRUB_CMDLINE_LINUX="cryptdevice=${LUKS_PATH}:${MAPPER_NAME}"

# If missing, add it and regenerate:
grub-mkconfig -o /boot/grub/grub.cfg
\`\`\`

### GRUB menu doesn't appear

\`\`\`bash
# Edit GRUB defaults
nano /etc/default/grub

# Set these values:
# GRUB_TIMEOUT=5
# GRUB_TIMEOUT_STYLE=menu

# Regenerate
grub-mkconfig -o /boot/grub/grub.cfg
\`\`\`

### Snapshots not appearing in GRUB

\`\`\`bash
# Check grub-btrfsd service
systemctl status grub-btrfsd

# Restart it
systemctl restart grub-btrfsd

# Manually regenerate
grub-mkconfig -o /boot/grub/grub.cfg
\`\`\`

### initramfs missing encrypt hook

\`\`\`bash
# Check mkinitcpio config
grep HOOKS /etc/mkinitcpio.conf

# Should include: encrypt
# Example: HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)

# If missing, edit and add 'encrypt' before 'filesystems'
nano /etc/mkinitcpio.conf

# Regenerate
mkinitcpio -P
\`\`\`

### Can't mount - wrong subvolume

\`\`\`bash
# List all subvolumes
mount ${BTRFS_DEVICE} /mnt
btrfs subvolume list /mnt

# Find your root subvolume (usually @ or @root)
# Unmount and remount with correct subvol
umount /mnt
mount -o subvol=@ ${BTRFS_DEVICE} /mnt
\`\`\`

---

## Quick Reference

| Action | Command |
|--------|---------|
| Open LUKS | \`cryptsetup open ${LUKS_PATH} ${MAPPER_NAME}\` |
| Mount root | \`mount -o subvol=${ROOT_SUBVOL} ${BTRFS_DEVICE} /mnt\` |
| Mount EFI | \`mount ${EFI_PART} /mnt${EFI_MOUNT}\` |
| Chroot | \`manjaro-chroot /mnt\` |
| Fix GRUB | \`mkinitcpio -P && grub-install --target=x86_64-efi --efi-directory=${EFI_MOUNT} --bootloader-id=manjaro && grub-mkconfig -o /boot/grub/grub.cfg\` |
| Exit | \`exit && umount -R /mnt && cryptsetup close ${MAPPER_NAME}\` |

---

*Keep this file on your phone or another device accessible during recovery.*
EOF

echo ""
echo "✅ Recovery gist created: ${OUTPUT}"
echo ""
echo "System detected:"
echo "  LUKS:  ${LUKS_PATH}"
echo "  BTRFS: ${BTRFS_DEVICE}"
echo "  EFI:   ${EFI_PART} → ${EFI_MOUNT}"
echo ""
echo "Upload ${OUTPUT} somewhere accessible (gist, phone, cloud)."
