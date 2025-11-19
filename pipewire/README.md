# PipeWire Configuration

## Problem
After NVIDIA driver upgrade (575 → 580), AG493UG7R4 monitor speakers stopped working. Audio was routed to wrong monitor (27G1G4).

## Cause
NVIDIA driver updates reset PipeWire's default HDMI output profile, switching from HDMI 2 (AG493UG7R4) to HDMI 1 (27G1G4).

## Solution
Force NVIDIA card to always use HDMI 2 profile via `50-nvidia-hdmi.conf.symlink`:

```
context.properties = {
    alsa.card.profile.default = "output:hdmi-stereo-extra1"
}
```

This config is symlinked to `~/.config/pipewire/pipewire.conf.d/` and persists across driver updates.

## Verification
```bash
# Check active profile
pactl list cards | grep -A 3 "Active Profile"

# Test audio
speaker-test -c 2 -t wav -l 1
```
