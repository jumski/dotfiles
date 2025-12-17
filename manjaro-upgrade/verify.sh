#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TIMESHIFT_CONFIG="/etc/timeshift/timeshift.json"

verify_fail() {
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                   TIMESHIFT NOT CONFIGURED                        ║${NC}"
    echo -e "${RED}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║  Your dev machine is UNPROTECTED from broken updates!             ║${NC}"
    echo -e "${RED}║                                                                   ║${NC}"
    echo -e "${RED}║  Open Timeshift GUI and configure:                                ║${NC}"
    echo -e "${RED}║    1. Select BTRFS snapshot type                                  ║${NC}"
    echo -e "${RED}║    2. Include @home subvolume in backups                          ║${NC}"
    echo -e "${RED}║    3. Enable: Boot (keep 3), Daily (keep 7), Weekly (keep 4)      ║${NC}"
    echo -e "${RED}║                                                                   ║${NC}"
    echo -e "${RED}║  Then re-run: ./manjaro-upgrade/verify.sh                         ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
}

# Check jq is available
if ! command -v jq &>/dev/null; then
    echo -e "${RED}FAIL: jq not installed (required for config parsing)${NC}"
    exit 1
fi

# Check config exists
if [[ ! -f "$TIMESHIFT_CONFIG" ]]; then
    echo -e "${RED}FAIL: Timeshift config not found${NC}"
    verify_fail
fi

# Read config values
get_config() {
    jq -r ".$1" "$TIMESHIFT_CONFIG"
}

# Check BTRFS mode
if [[ "$(get_config btrfs_mode)" != "true" ]]; then
    echo -e "${RED}FAIL: Timeshift not in BTRFS mode${NC}"
    verify_fail
fi

# Check backup device is set
if [[ -z "$(get_config backup_device_uuid)" || "$(get_config backup_device_uuid)" == "null" ]]; then
    echo -e "${RED}FAIL: Timeshift backup device not configured${NC}"
    verify_fail
fi

# Check @home subvolume is included
if [[ "$(get_config include_btrfs_home_for_backup)" != "true" ]]; then
    echo -e "${RED}FAIL: @home subvolume not included in backups${NC}"
    verify_fail
fi

# Check schedules are enabled
if [[ "$(get_config schedule_boot)" != "true" ]]; then
    echo -e "${RED}FAIL: Boot snapshots not enabled${NC}"
    verify_fail
fi

if [[ "$(get_config schedule_daily)" != "true" ]]; then
    echo -e "${RED}FAIL: Daily snapshots not enabled${NC}"
    verify_fail
fi

if [[ "$(get_config schedule_weekly)" != "true" ]]; then
    echo -e "${RED}FAIL: Weekly snapshots not enabled${NC}"
    verify_fail
fi

echo -e "${GREEN}Timeshift: OK (BTRFS, @home, boot/daily/weekly enabled)${NC}"
