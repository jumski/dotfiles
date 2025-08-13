#!/bin/bash
# Firefox GPU switching based on power profile

GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ "$GOVERNOR" = "powersave" ]; then
    # Use Intel GPU for power saving
    export MOZ_DISABLE_RDD_SANDBOX=1
    export LIBVA_DRIVER_NAME=iHD
    export MOZ_X11_EGL=1
    /usr/bin/firefox "$@"
else
    # Use NVIDIA GPU for performance
    export MOZ_DISABLE_RDD_SANDBOX=1
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    export MOZ_X11_EGL=1
    /usr/bin/firefox "$@"
fi