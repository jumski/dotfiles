#!/bin/bash
set -e

echo "Setting up safe Manjaro upgrade system with BTRFS snapshots..."

# Check if running on BTRFS
ROOT_FS=$(df -T / | tail -1 | awk '{print $2}')
if [[ "$ROOT_FS" != "btrfs" ]]; then
    echo "ERROR: Root filesystem is $ROOT_FS, not BTRFS."
    echo "This setup requires BTRFS for snapshot functionality."
    exit 1
fi

echo "BTRFS filesystem detected."

# Install required packages
echo "Installing required packages..."
sudo pacman -S --needed --noconfirm timeshift grub-btrfs

# Install AUR package for autosnap
if ! pacman -Q timeshift-autosnap-manjaro &>/dev/null; then
    echo "Installing timeshift-autosnap-manjaro from AUR..."
    yay -S --needed --noconfirm timeshift-autosnap-manjaro
else
    echo "timeshift-autosnap-manjaro already installed."
fi

# Enable cronie for scheduled snapshots
echo "Enabling cronie service..."
sudo systemctl enable --now cronie.service

# Configure grub-btrfsd for Timeshift
GRUB_BTRFSD_OVERRIDE="/etc/systemd/system/grub-btrfsd.service.d/override.conf"
if [[ ! -f "$GRUB_BTRFSD_OVERRIDE" ]]; then
    echo "Configuring grub-btrfsd for Timeshift snapshots..."
    sudo mkdir -p /etc/systemd/system/grub-btrfsd.service.d
    sudo tee "$GRUB_BTRFSD_OVERRIDE" > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
EOF
    sudo systemctl daemon-reload
else
    echo "grub-btrfsd override already configured."
fi

# Enable and start grub-btrfsd
echo "Enabling grub-btrfsd service..."
sudo systemctl enable --now grub-btrfsd

# Regenerate GRUB config
echo "Regenerating GRUB configuration..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Open Timeshift GUI and configure:"
echo "   - Select BTRFS snapshot type"
echo "   - Enable scheduled snapshots (weekly recommended)"
echo "   - Create your first snapshot"
echo ""
echo "2. Snapshots will now be created automatically before each upgrade"
echo "3. Snapshots will appear in GRUB boot menu for easy recovery"
echo ""
echo "See README.md for safe upgrade procedure and recovery instructions."
