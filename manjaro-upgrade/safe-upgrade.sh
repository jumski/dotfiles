#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Manjaro Safe Upgrade ===${NC}"
echo ""

# Generate recovery gist
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIST_SCRIPT="${SCRIPT_DIR}/generate-recovery-gist.sh"
if [[ -x "$GIST_SCRIPT" ]]; then
    echo -e "${YELLOW}Generating recovery gist...${NC}"
    "$GIST_SCRIPT"
    GIST_FILE="${SCRIPT_DIR}/$(hostname)-upgrade-recovery.md"
    echo ""
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}║   ⚠️  IMPORTANT: SAVE YOUR RECOVERY GIST BEFORE PROCEEDING ⚠️   ║${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}║   Upload to GitHub Gist, send to phone, or save somewhere     ║${NC}"
    echo -e "${YELLOW}║   accessible OUTSIDE this machine in case GRUB breaks!        ║${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}║   File: ${GIST_FILE}${NC}"
    echo -e "${YELLOW}║                                                                ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    read -p "Have you saved the recovery gist? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Please save the recovery gist first, then run safe-upgrade again.${NC}"
        exit 1
    fi
    echo ""
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}ERROR: Don't run as root. Script will use sudo when needed.${NC}"
    exit 1
fi

# Check for available updates first
echo -e "${YELLOW}Checking for updates...${NC}"
if ! checkupdates &>/dev/null; then
    echo -e "${GREEN}No updates available.${NC}"
    exit 0
fi

echo -e "${YELLOW}Updates available:${NC}"
checkupdates
echo ""

# Create snapshot
SNAPSHOT_COMMENT="Before upgrade $(date '+%Y-%m-%d %H:%M')"
echo -e "${YELLOW}Creating snapshot: ${SNAPSHOT_COMMENT}${NC}"
sudo timeshift --create --comments "$SNAPSHOT_COMMENT" --tags D

echo ""
echo -e "${GREEN}Snapshot created successfully.${NC}"
echo ""

# Show recent snapshots
echo -e "${BLUE}Recent snapshots:${NC}"
sudo timeshift --list | tail -10
echo ""

# Confirm upgrade
read -p "Proceed with upgrade? [Y/n] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Upgrade cancelled."
    exit 0
fi

# Perform upgrade
echo ""
echo -e "${YELLOW}Running system upgrade...${NC}"
sudo pacman -Syu

echo ""
echo -e "${GREEN}=== Upgrade complete ===${NC}"
echo ""
echo -e "If something breaks after reboot:"
echo -e "  1. Reboot and select ${BLUE}Manjaro Linux snapshots${NC} in GRUB"
echo -e "  2. Boot into snapshot from before this upgrade"
echo -e "  3. Open Timeshift and restore that snapshot"
