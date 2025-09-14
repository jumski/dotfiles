#!/bin/bash
echo "Loading combined crontab from multiple sources..."

# Create temporary combined crontab file
TEMP_CRONTAB=$(mktemp)

# Add main crontab
if [[ -f "/home/jumski/.dotfiles/cron/crontab" ]]; then
    echo "# Main cron entries" >> "$TEMP_CRONTAB"
    cat /home/jumski/.dotfiles/cron/crontab >> "$TEMP_CRONTAB"
    echo "" >> "$TEMP_CRONTAB"
fi

# Add todoist-helper crontab
if [[ -f "/home/jumski/.dotfiles/todoist-helper/crontab" ]]; then
    echo "# Todoist urgent tasks monitoring" >> "$TEMP_CRONTAB"
    cat /home/jumski/.dotfiles/todoist-helper/crontab >> "$TEMP_CRONTAB"
    echo "" >> "$TEMP_CRONTAB"
fi

# Load combined crontab
crontab "$TEMP_CRONTAB"
rm "$TEMP_CRONTAB"

echo "✓ Combined crontab loaded successfully"
