# Lenovo Tab M11 (TB-330FU): Disabling Guest Account & Rooting Guide

## The Problem

The Lenovo Tab M11 tablet has a **Guest account** feature that allows anyone to create a temporary user profile by swiping down the notification bar and tapping the user icon. This is a security/privacy concern when:

- Children could bypass parental controls by switching to Guest mode
- The tablet is shared but you want to restrict access to your apps/data
- You want full control over who can use the device

**The issue:** Unlike many Android tablets, the Lenovo Tab M11 does NOT expose the "Multiple Users" or "Guest account" settings in the standard Settings app, making it impossible to disable this feature through normal means.

## What We Wanted to Accomplish

Disable the Guest account feature so that:
1. No one can create a new Guest profile from the lock screen
2. The user switching icon is removed or disabled
3. Only the primary account can access the tablet

## What We Tried and What Failed

### Attempt 1: ADB Commands (Partial Success)

```bash
adb shell settings put global guest_user_enabled 0
adb shell settings put global user_switcher_enabled 0
adb shell pm disable-user --user 0 com.android.managedprovisioning
```

**Result:** Commands executed without errors, but the Guest account feature remained accessible. These commands work on some Android devices but not consistently on the Tab M11.

### Attempt 2: Setting System Properties (Failed)

```bash
adb shell setprop fw.max_users 1
```

**Result:** `Failed to set property 'fw.max_users' to '1'` - This requires root access to modify system properties.

### Attempt 3: Looking for Hidden Settings (Failed)

Searched through all Settings menus including Developer Options. The Tab M11 does not expose Multiple Users settings in the UI, unlike stock Android or other tablet manufacturers.

---

## Option 1: Disable Guest Account WITHOUT Root (Try This First!)

This method uses native Android functionality and carries **zero risk** to your device.

### Step 1: Remove Existing Guest Account

1. Swipe down from the top of the screen **twice** to open Quick Settings
2. Tap the **User icon** (profile picture in the top-right area)
3. Tap **Guest** to switch to the Guest account
4. Once in Guest mode, swipe down **twice** again
5. Tap the **User icon**
6. Select **Remove Guest** to delete the guest profile

### Step 2: Prevent New Guest Accounts

1. After returning to your main account, swipe down **twice**
2. Tap the **User icon**
3. Look for **More Settings** or a gear icon
4. Toggle **OFF** the option "Add user when device is locked" or "Add users from lock screen"

### Step 3: Secure Your Main Account

1. Go to **Settings > Security > Screen Lock**
2. Set a **PIN, Password, or Pattern**
3. This prevents unauthorized access to your main profile

### Step 4: Check for Multiple Users Setting

Some Tab M11 firmware versions may have this setting:

1. Go to **Settings > System**
2. Look for **Multiple Users** or **Users**
3. If present, you can toggle the entire feature off

### Verification

After completing these steps:
- The Guest option should no longer appear in the user switcher
- New users cannot be added from the lock screen
- Only your password-protected main account is accessible

**If this works for you, stop here!** No need to root the device.

---

## Option 2: Root the Device (If Option 1 Fails)

If the native Android method doesn't work on your firmware version, rooting allows you to modify system files directly.

### Important: The Tab M11 Rooting Challenge

The Lenovo Tab M11 (TB-330FU) has a **non-standard boot architecture** that makes it more difficult to root than typical Android devices:

- Uses MediaTek MT6768 (Helio G85) processor
- Does **NOT** follow Google's standard Generic Kernel Image (GKI) architecture
- The generic ramdisk is in `vendor_boot` partition, not the standard `boot` partition
- Standard Magisk boot.img patching **appears to work but produces no root access**

This is why many users report: "I followed all the steps, Magisk says it's installed, but root doesn't work."

### Requirements

| Item | Notes |
|------|-------|
| **Magisk 30.3+** | Earlier versions don't support vendor_boot patching |
| **mtkclient** | For bootloader unlock and partition extraction |
| **ADB/Fastboot** | Android platform tools |
| **Original firmware** | From Lenovo RSA (Windows) or mirrors.lolinet.com |
| **Linux PC** | Recommended (mtkclient works natively) |

### Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Bootloop | Medium | Can recover with Lenovo RSA (Windows) |
| Brick | Low | BROM access via mtkclient allows recovery |
| Root not appearing | High | Use dual-partition patching method below |
| Warranty void | Certain | Bootloader unlock is logged permanently |

### Step-by-Step Rooting Process

#### Phase 1: Preparation

1. **Install mtkclient on Linux:**
   ```bash
   pip install mtkclient
   ```

2. **Create udev rules for MediaTek devices:**
   ```bash
   sudo nano /etc/udev/rules.d/51-android.rules
   ```
   Add this line:
   ```
   SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ATTR{idProduct}=="7e7d", MODE="0666", GROUP="plugdev"
   ```
   Then reload:
   ```bash
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

3. **Enable Developer Options on tablet:**
   - Go to Settings > About Tablet
   - Tap "Build Number" 7 times
   - Go to Settings > System > Developer Options
   - Enable "OEM Unlocking"
   - Enable "USB Debugging"

4. **Download Magisk 30.3+ APK** from: https://github.com/topjohnwu/Magisk/releases

5. **Get firmware** (for boot.img):
   - Option A: Lenovo Rescue & Smart Assistant (Windows) - most reliable
   - Option B: https://mirrors.lolinet.com/firmware/lenowow/2023/Tab_M11_2024/TB330FU/

#### Phase 2: Unlock Bootloader

1. **Power off the tablet completely**

2. **Enter BROM mode:**
   - Hold **Volume Up + Volume Down + Power** simultaneously
   - While holding, connect USB cable to computer
   - Release buttons when mtkclient detects the device

3. **Unlock bootloader:**
   ```bash
   sudo mtk da seccfg unlock
   ```

4. **Reboot and verify:**
   - The tablet will factory reset (this is normal)
   - Complete initial setup
   - Check Developer Options - "OEM Unlocking" should be grayed out saying "Bootloader is already unlocked"

#### Phase 3: Extract Boot Partitions (Critical Step!)

This is where the Tab M11 differs from standard devices. You must extract BOTH partitions:

1. **Power off tablet and enter BROM mode again**

2. **Launch mtkclient GUI:**
   ```bash
   sudo python mtk_gui.py
   ```

3. **Extract partitions:**
   - Select "Read" option
   - Extract `boot_a` partition → save as `boot_a.img`
   - Extract `vendor_boot_a` partition → save as `vendor_boot_a.img`

4. **Transfer both files to the tablet's internal storage**

#### Phase 4: Patch Both Images with Magisk

1. **Install Magisk APK** on the tablet

2. **Patch boot_a.img:**
   - Open Magisk app
   - Tap "Install" next to Magisk
   - Select "Select and Patch a File"
   - Choose `boot_a.img`
   - Wait for patching to complete
   - Rename output to `magisk_patched_boot.img`

3. **Patch vendor_boot_a.img:**
   - Tap "Install" again
   - Select "Select and Patch a File"
   - Choose `vendor_boot_a.img`
   - Wait for patching to complete
   - Rename output to `magisk_patched_vendor_boot.img`

4. **Transfer both patched files back to computer**

#### Phase 5: Flash Both Patched Images

**Using Fastboot:**
```bash
adb reboot bootloader

# Wait for device to enter fastboot mode
fastboot devices

# Flash both partitions
fastboot flash boot_a magisk_patched_boot.img
fastboot flash boot_b magisk_patched_boot.img
fastboot flash vendor_boot_a magisk_patched_vendor_boot.img
fastboot flash vendor_boot_b magisk_patched_vendor_boot.img

# Reboot
fastboot reboot
```

**Or using mtkclient:**
1. Enter BROM mode
2. Use mtkclient GUI "Write" option
3. Write patched boot to `boot_a` and `boot_b`
4. Write patched vendor_boot to `vendor_boot_a` and `vendor_boot_b`
5. Reboot

#### Phase 6: Verify Root Access

1. Open Magisk app
2. Check that "Superuser" section is now accessible
3. Install "Root Checker" from Play Store to confirm

### Troubleshooting

#### "Root not appearing" after flashing
- Ensure you patched AND flashed BOTH `boot` AND `vendor_boot`
- Verify you're using Magisk 30.3 or later
- Try flashing to both A and B slots

#### Device stuck in fastboot
```bash
fastboot reboot
```
If unresponsive, use mtkclient in BROM mode to flash original boot.img

#### Bootloop after flashing
1. Enter BROM mode (Vol+, Vol-, Power while connecting USB)
2. Use mtkclient to flash original unpatched boot.img
3. Or use Lenovo RSA (Windows) to restore full stock firmware

#### Orange "device corrupted" warning at boot
This is normal after unlocking bootloader. Press power button to continue boot.

### After Rooting: Disable Guest Account

Once rooted, you can permanently disable guest accounts:

1. **Install a root file manager** (e.g., Solid Explorer with root addon)

2. **Edit build.prop:**
   ```
   /system/build.prop
   ```
   Add at the end:
   ```
   fw.max_users=1
   ```

3. **Or use a SQLite editor** to modify:
   ```
   /data/data/com.android.providers.settings/databases/settings.db
   ```
   In the "Global" table, set `guest_user_enabled` to `0`

4. **Reboot the tablet**

---

## Resources

- XDA Comprehensive Guide: https://xdaforums.com/t/comprehensive-guide-to-rooting-the-lenovo-tab-m11-tb-330fu-tutorial.4703089/
- XDA Alternative Guide: https://xdaforums.com/t/root-tb-330fu-rooting-lenovo-tab-m11.4694828/
- Magisk GitHub Issue (vendor_boot): https://github.com/topjohnwu/Magisk/issues/9263
- Firmware Downloads: https://mirrors.lolinet.com/firmware/lenowow/2023/Tab_M11_2024/TB330FU/
- mtkclient: https://github.com/bkerler/mtkclient

## Document Info

- **Created:** December 2025
- **Device:** Lenovo Tab M11 (TB-330FU)
- **Android versions covered:** 13, 14, 15, 16, 17
- **Magisk version required:** 30.3+
