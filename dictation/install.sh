#!/bin/bash
# Dictation module installation script

echo "Installing dictation module..."

# Check if NAS Dev directory exists
NAS_DEV_DIR="$HOME/SynologyDrive/Areas/Dev"
if [ ! -d "$NAS_DEV_DIR" ]; then
    echo -e "\033[31mERROR: NAS not mounted or Dev directory missing!\033[0m"
    echo "Expected path: $NAS_DEV_DIR"
    echo "Please ensure your Synology Drive is properly mounted."
    exit 1
fi

# Create recordings directory on NAS
RECORD_DIR="$NAS_DEV_DIR/dictation-data"
mkdir -p "$RECORD_DIR"
echo "✓ Created recordings directory: $RECORD_DIR"

# Install crontab entry (append if not already present)
CRON_ENTRY="0 3 * * * find ~/SynologyDrive/Areas/Dev/dictation-data -type f -name \"*.ogg\" -mtime +28 -delete 2>/dev/null"
CRON_COMMENT="# Cleanup old dictation recordings"

# Check if entry already exists
if ! crontab -l 2>/dev/null | grep -F "$CRON_ENTRY" > /dev/null; then
    echo "Adding dictation cleanup to crontab..."
    (crontab -l 2>/dev/null; echo "$CRON_COMMENT"; echo "$CRON_ENTRY") | crontab -
    echo "✓ Crontab entry added"
else
    echo "✓ Crontab entry already exists"
fi

echo "✓ Dictation module installed successfully"