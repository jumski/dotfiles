# Windows Dual-Boot Installation Plan for Your System

## System Analysis Summary

Based on your system scan:
- **Current OS**: Manjaro Linux on encrypted BTRFS (LUKS)
- **Boot Mode**: UEFI with GRUB 2.12
- **Secure Boot**: Disabled
- **TPM2**: Not supported (Windows 11 bypass needed)
- **Current Drives**:
  - **nvme0n1** (1.9TB ADATA SX8200PNP): Linux system with LUKS encryption
  - **sda** (476.9GB SSDPR-CX400-512): Unused, has old EFI and ext4 partitions
- **Available SATA ports**: Yes (2 controllers detected)
- **CPU**: AMD Ryzen 7 2700X (Windows 11 compatible)
- **RAM**: 62GB (excellent for Windows)
- **GPU**: NVIDIA RTX 3090 (great for Windows)

## Recommended Approach

### Option 1: Use Existing SDA Drive (RECOMMENDED)
Your 476GB SSD (`/dev/sda`) appears unused and already has:
- 300MB EFI partition
- 476.6GB ext4 partition (can be wiped for Windows)

This is perfect for Windows installation without buying new hardware!

### Option 2: Add New Drive
If you want to keep sda for other purposes, add a new SATA or NVMe drive.

## Phase 1: Preparation

### 1.1 Backup Critical Data
```bash
# Backup your current GRUB configuration
sudo cp /boot/grub/grub.cfg /boot/grub/grub.cfg.backup
sudo cp -r /boot/efi/EFI /boot/efi/EFI.backup

# Document current partition UUIDs
sudo blkid > ~/partition-uuids-backup.txt

# Create Timeshift backup (optional but recommended)
sudo timeshift --create --comments "Before Windows dual-boot"
```

### 1.2 Prepare SDA Drive (if using Option 1)
```bash
# Verify sda is not mounted
mount | grep sda
# Should return nothing

# Check what's on sda2 (if curious)
sudo mkdir -p /mnt/temp
sudo mount -r /dev/sda2 /mnt/temp
ls /mnt/temp
sudo umount /mnt/temp

# If you're sure you don't need anything on sda, we'll wipe it during Windows install
```

### 1.3 Create Windows 11 Installation Media

Since your system lacks TPM 2.0, you'll need Windows 11 with TPM bypass:

**Method A: Official ISO with Registry Bypass**
```bash
# Download Windows 11 ISO
wget -O Win11.iso "https://www.microsoft.com/software-download/windows11"

# Use Ventoy (recommended for flexibility)
# Download Ventoy from https://github.com/ventoy/Ventoy/releases
wget https://github.com/ventoy/Ventoy/releases/download/v1.0.99/ventoy-1.0.99-linux.tar.gz
tar xzf ventoy-1.0.99-linux.tar.gz
cd ventoy-1.0.99
sudo ./Ventoy2Disk.sh -i /dev/sdX  # Replace sdX with your USB drive

# Copy ISO to USB
cp Win11.iso /media/your-usb/
```

**Method B: Modified ISO (Easier)**
Use Rufus on a Windows machine or a tool like WoeUSB-ng with TPM check removal.

### 1.4 TPM Bypass Registry File
Create `bypass.reg` on your USB drive:
```registry
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig]
"BypassTPMCheck"=dword:00000001
"BypassSecureBootCheck"=dword:00000001
"BypassRAMCheck"=dword:00000001
```

## Phase 2: BIOS/UEFI Configuration

Enter BIOS (usually DEL or F2 on boot):

1. **Secure Boot**: Keep disabled (already is)
2. **CSM/Legacy**: Ensure disabled (pure UEFI mode)
3. **SATA Mode**: Verify AHCI mode
4. **Boot Order**: Temporarily set USB first
5. **Fast Boot**: Disable if enabled

## Phase 3: Windows Installation

### 3.1 Boot from Installation USB
1. Insert Windows USB
2. Reboot and enter boot menu (F12 usually)
3. Select USB in UEFI mode

### 3.2 Installation Process
1. **Initial Setup**: 
   - Language, Time, Keyboard
   - Click "Install Now"

2. **TPM Bypass** (when you see system requirements error):
   - Press `Shift + F10` to open Command Prompt
   - Run: `regedit`
   - Navigate to: `HKEY_LOCAL_MACHINE\SYSTEM\Setup`
   - Create new key: `LabConfig`
   - Add DWORD values:
     - `BypassTPMCheck` = 1
     - `BypassSecureBootCheck` = 1
   - Close regedit and Command Prompt
   - Click back and try again

3. **License**: Skip for now (activate later)

4. **Installation Type**: Custom (advanced)

5. **Drive Selection** ⚠️ CRITICAL:
   - You'll see:
     - Drive 0: 476.9GB (sda) 
     - Drive 1: 1.9TB (nvme0n1) - DO NOT TOUCH THIS!
   
   - Select Drive 0 (sda):
     - Delete Partition 2 (ext4)
     - Delete Partition 1 (EFI) 
     - Select unallocated space
     - Click "New" → Apply → Windows creates partitions
     - Select the primary partition
     - Click Next

6. **Installation**: Windows copies files and reboots

7. **OOBE Setup**: 
   - Region/Keyboard
   - Network (can skip for local account)
   - Account setup
   - Privacy settings

## Phase 4: Post-Installation Dual-Boot Setup

### 4.1 Boot Back to Linux
After Windows installation, GRUB might not appear. To boot Linux:
1. Enter BIOS boot menu (F12)
2. Select: "ADATA SX8200PNP" or "Manjaro" or "GRUB"

### 4.2 Restore and Update GRUB
```bash
# Reinstall GRUB to the primary drive's EFI
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Manjaro

# Enable os-prober to detect Windows
sudo nano /etc/default/grub
# Add or uncomment: GRUB_DISABLE_OS_PROBER=false

# Update GRUB configuration
sudo update-grub
# Or on Manjaro:
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Verify Windows was detected
grep -i windows /boot/grub/grub.cfg
```

### 4.3 Set Default Boot Entry
```bash
# List all boot entries
sudo efibootmgr

# Set Manjaro/GRUB as first boot option
sudo efibootmgr -o XXXX,YYYY  # Replace with actual numbers
```

## Phase 5: System Optimization

### 5.1 Fix Time Sync Issue
Windows uses local time, Linux uses UTC:

**In Linux:**
```bash
timedatectl set-local-rtc 1 --adjust-system-clock
```

### 5.2 Disable Windows Fast Startup
In Windows:
1. Control Panel → Power Options
2. "Choose what power button does"
3. "Change settings currently unavailable"
4. Uncheck "Turn on fast startup"

### 5.3 Install Windows Drivers
- **NVIDIA**: Download from nvidia.com (RTX 3090 drivers)
- **Chipset**: AMD 400 series from amd.com
- **Network**: Should work out of box (Realtek)

### 5.4 Optional: Shared Data Partition
Since you have space on sda, you could shrink Windows partition and create shared NTFS:
```bash
# After Windows is settled, from Linux:
sudo ntfs-3g /dev/sda2 /mnt/windows -o ro
# Check Windows partition usage

# If you want to create shared partition, use Windows Disk Management
# to shrink C: and create new NTFS partition
```

## Phase 6: GRUB Customization

### 6.1 Improve GRUB Menu
```bash
sudo nano /etc/default/grub

# Recommended settings:
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_TIMEOUT=10
GRUB_TIMEOUT_STYLE=menu
GRUB_DISABLE_OS_PROBER=false

# Apply changes
sudo update-grub
```

### 6.2 Set Preferred Default OS
```bash
# After reboot, check menu entries
sudo grep menuentry /boot/grub/grub.cfg | grep -n Windows

# Set Windows as default (if entry #3)
sudo grub-set-default 3

# Or set to remember last choice
sudo grub-set-default saved
```

## Troubleshooting

### Cannot see GRUB after Windows install
```bash
# Boot from Manjaro Live USB
# Mount your system
sudo mount /dev/mapper/luks-98e65cd2-8687-44f2-bee3-64ccc6124b70 /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
sudo arch-chroot /mnt
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
exit
```

### Windows doesn't appear in GRUB
```bash
# Install os-prober
sudo pacman -S os-prober

# Mount Windows EFI if using separate
sudo mkdir -p /mnt/win-efi
sudo mount /dev/sda1 /mnt/win-efi

# Regenerate GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### TPM Error During Windows Install
- Use the registry bypass method above
- Or use Rufus to create USB with TPM checks removed

## Important Notes

⚠️ **Your Linux is encrypted with LUKS** - Windows cannot access it (this is good for security)

⚠️ **Never use Windows Disk Management** on nvme0n1 partitions

⚠️ **Keep your encryption password safe** - you'll need it every Linux boot

⚠️ **EFI Partitions**: You have two (nvme0n1p1 for Linux, sda1 potential for Windows). This can actually be beneficial for isolation.

## Checklist

- [ ] Backup GRUB configuration
- [ ] Backup partition UUIDs
- [ ] Create Windows 11 USB with TPM bypass
- [ ] Verify sda is not needed/backed up
- [ ] BIOS settings checked
- [ ] 2-3 hours allocated for installation
- [ ] Patience and coffee ready ☕

## Next Steps

1. Run the backup commands from Phase 1.1
2. Create Windows installation USB with TPM bypass
3. Proceed with installation on `/dev/sda`
4. Update GRUB after installation
5. Enjoy your dual-boot system!

The 476GB SSD should be plenty for Windows 11 and some applications. Your encrypted Linux system will remain completely separate and secure.