#!/usr/bin/env bash
set -euo pipefail

# vmw install script - idempotent setup for KVM Claude Farm
# Assumes packages from packages.pacman are already installed
# Runs as root, uses su for user-specific operations

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine target user from dotfiles ownership
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER=$(stat -c '%U' "$SCRIPT_DIR")
TARGET_HOME=$(eval echo "~$TARGET_USER")

VMW_CONFIG_DIR="${TARGET_HOME}/.config/vmw"
VMW_SECRETS_FILE="${VMW_CONFIG_DIR}/secrets.env"
VMW_INSTANCES_DIR="${VMW_CONFIG_DIR}/instances"

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
step() { echo -e "\n${GREEN}==>${NC} $1"; }

# Helper to run command as target user
as_user() {
    if [[ $EUID -eq 0 ]]; then
        su "$TARGET_USER" -c "$*"
    else
        eval "$*"
    fi
}

step "Checking vmw setup..."

# --- 1. Enable KVM modules auto-load ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KVM_CONF_SRC="${SCRIPT_DIR}/kvm.conf"
KVM_CONF_DST="/etc/modules-load.d/kvm.conf"

if [[ -f "$KVM_CONF_DST" ]] && diff -q "$KVM_CONF_SRC" "$KVM_CONF_DST" &>/dev/null; then
    info "KVM modules config already installed"
else
    cp "$KVM_CONF_SRC" "$KVM_CONF_DST"
    info "Installed KVM modules config to $KVM_CONF_DST"
fi

# Load KVM modules now if not loaded
if [[ -e /dev/kvm ]]; then
    info "KVM device available"
else
    warn "KVM device not available, loading modules..."
    modprobe kvm
    modprobe kvm_amd
    info "KVM modules loaded"
fi

# --- 2. Enable libvirtd service ---
if systemctl is-active --quiet libvirtd; then
    info "libvirtd service is running"
else
    warn "libvirtd service is not running, enabling..."
    systemctl enable --now libvirtd
    info "libvirtd service enabled and started"
fi

# --- 3. Add user to libvirt group ---
if id -nG "$TARGET_USER" | grep -qw libvirt; then
    info "User $TARGET_USER is in libvirt group"
else
    warn "User $TARGET_USER is not in libvirt group, adding..."
    usermod -aG libvirt "$TARGET_USER"
    warn "Added to libvirt group - LOG OUT AND BACK IN for this to take effect"
fi

# --- 4. Enable avahi-daemon for mDNS ---
if systemctl is-active --quiet avahi-daemon; then
    info "avahi-daemon service is running"
else
    warn "avahi-daemon service is not running, enabling..."
    systemctl enable --now avahi-daemon
    info "avahi-daemon service enabled and started"
fi

# --- 5. Check nsswitch.conf for mDNS ---
if grep -q 'mdns_minimal' /etc/nsswitch.conf; then
    info "nsswitch.conf has mdns_minimal configured"
else
    warn "nsswitch.conf missing mdns_minimal"
    echo "    Please edit /etc/nsswitch.conf and ensure the hosts line includes mdns_minimal:"
    echo "    hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files dns"
fi

# --- 6. Create config directory structure ---
if [[ -d "$VMW_CONFIG_DIR" ]]; then
    info "Config directory exists: $VMW_CONFIG_DIR"
else
    as_user "mkdir -p '$VMW_CONFIG_DIR'"
    info "Created config directory: $VMW_CONFIG_DIR"
fi

if [[ -d "$VMW_INSTANCES_DIR" ]]; then
    info "Instances directory exists: $VMW_INSTANCES_DIR"
else
    as_user "mkdir -p '$VMW_INSTANCES_DIR'"
    info "Created instances directory: $VMW_INSTANCES_DIR"
fi

# --- 7. Create secrets.env template ---
if [[ -f "$VMW_SECRETS_FILE" ]]; then
    info "Secrets file exists: $VMW_SECRETS_FILE"
else
    as_user "cat > '$VMW_SECRETS_FILE'" << 'EOF'
# VMW secrets - API keys for VMs
# These are separate from your host keys for security isolation
# If a VM is compromised, revoke these without affecting host

# ANTHROPIC_API_KEY=sk-ant-xxx
# PERPLEXITY_API_KEY=pplx-xxx
# OPENAI_API_KEY=sk-xxx
EOF
    as_user "chmod 600 '$VMW_SECRETS_FILE'"
    info "Created secrets template: $VMW_SECRETS_FILE"
    warn "Edit $VMW_SECRETS_FILE to add your API keys"
fi

# --- 8. Check libvirt default network ---
if virsh net-info default &>/dev/null; then
    if virsh net-info default 2>/dev/null | grep -q 'Active:.*yes'; then
        info "libvirt default network is active"
    else
        warn "libvirt default network exists but is not active, starting..."
        virsh net-start default
        virsh net-autostart default
        info "libvirt default network started"
    fi
else
    warn "libvirt default network does not exist"
    echo "    Run: virsh net-define /usr/share/libvirt/networks/default.xml"
    echo "    Then: virsh net-start default && virsh net-autostart default"
fi

# --- 9. Check for SSH key ---
if [[ -f "${TARGET_HOME}/.ssh/id_ed25519.pub" ]] || [[ -f "${TARGET_HOME}/.ssh/id_rsa.pub" ]]; then
    info "SSH public key found (will be injected into VMs)"
else
    warn "No SSH public key found at ~/.ssh/id_ed25519.pub or ~/.ssh/id_rsa.pub"
    echo "    Generate one with: ssh-keygen -t ed25519"
fi

# --- Summary ---
step "Setup summary"
echo ""
echo "Config directory:  $VMW_CONFIG_DIR"
echo "Secrets file:      $VMW_SECRETS_FILE"
echo "Instances dir:     $VMW_INSTANCES_DIR"
echo ""
echo "Next steps:"
echo "  1. Log out and back in (if added to libvirt group)"
echo "  2. Edit $VMW_SECRETS_FILE with your API keys"
echo "  3. Run: vmw setup    (to download Debian golden image)"
echo "  4. Run: vmw spawn /path/to/worktree"
echo ""
