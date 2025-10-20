# Monitor Flickering Issue - DisplayPort

**Date:** 2025-10-17
**Hardware:** NVIDIA RTX 3090 + AOC AG493UG7R4 (5120x1440)
**Connection:** DisplayPort (DP-4)

## Symptoms
- Monitor flickers with white lines every 10-20 seconds
- Brief visual glitch lasting a split second
- Started happening without any hardware changes

## Root Cause
DDC/CI communication interference between KDE PowerDevil and the monitor causing brief disconnect/reconnect events on the DisplayPort connection.

**Evidence from logs:**
```
DDCA_EVENT_DISPLAY_DISCONNECTED, card1-DP-3
DDCA_EVENT_DISPLAY_CONNECTED, card1-DP-3
```

## Solutions (try in order)

### 1. Disable DDC/CI in PowerDevil (most likely fix)

**Option A - Command line:**
```bash
kwriteconfig5 --file powermanagementprofilesrc --group AC --group DPMSControl --key idleTime 0
```

**Option B - GUI:**
- System Settings → Power Management → Energy Saving
- Disable "Screen Energy Saving"
- Or disable DDC/CI control entirely in display settings

### 2. Reseat DisplayPort Cable
Even without moving it, connectors can develop poor contact over time. Unplug and firmly reconnect both ends (GPU and monitor).

### 3. Try Different DP Port on GPU
RTX 3090 has multiple DisplayPort outputs. Try switching to another port.

### 4. Disable DisplayPort Power Saving

```bash
sudo nvidia-settings
```
- Navigate to: GPU 0 → PowerMizer
- Set "Preferred Mode" to "Maximum Performance"

### 5. Add Kernel Parameters

Edit `/etc/default/grub`:
```bash
GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 video.use_native_backlight=1"
```

Then update grub:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot
```

## System Info
- OS: Manjaro Linux 6.15.11-2-MANJARO
- GPU: NVIDIA GeForce RTX 3090
- Driver: NVIDIA 575.64.05
- Desktop: KDE Plasma on X11
- Monitor: AOC AG493UG7R4 (ultrawide 5120x1440)
- Connection: DisplayPort

## GPU Status (at diagnosis time)
- Temperature: 49°C (normal)
- Power: 36W / 370W
- No GPU errors in logs
- Driver loaded successfully
