#!/bin/bash
# Dictation module installation script

echo "Installing dictation module..."

# Create recordings directory
mkdir -p ~/.dictation_recordings

# Install crontab entry (append if not already present)
CRON_ENTRY="0 3 * * * find ~/.dictation_recordings -type f -name \"*.wav\" -mtime +28 -delete 2>/dev/null"
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