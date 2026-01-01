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

# --- 0. Check required dependencies ---
REQUIRED_DEPS=(virsh qemu-img qemu-system-x86_64 genisoimage wget)
MISSING_DEPS=()

for dep in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        MISSING_DEPS+=("$dep")
    fi
done

# virtiofsd is installed at /usr/lib/virtiofsd on Arch/Manjaro
if ! command -v virtiofsd &>/dev/null && [[ ! -x /usr/lib/virtiofsd ]]; then
    MISSING_DEPS+=("virtiofsd")
fi

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    error "Missing dependencies: ${MISSING_DEPS[*]}"
    echo "    Install with: yay -S ${MISSING_DEPS[*]}"
    exit 1
fi
info "All dependencies available"

# --- 1. Enable KVM modules auto-load ---
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

# --- 4b. Enable avahi reflector for VM mDNS ---
AVAHI_CONF="/etc/avahi/avahi-daemon.conf"
if grep -q '^enable-reflector=yes' "$AVAHI_CONF" 2>/dev/null; then
    info "avahi reflector is enabled"
else
    if grep -q '#enable-reflector=no' "$AVAHI_CONF" 2>/dev/null; then
        sed -i 's/#enable-reflector=no/enable-reflector=yes/' "$AVAHI_CONF"
    elif grep -q 'enable-reflector=no' "$AVAHI_CONF" 2>/dev/null; then
        sed -i 's/enable-reflector=no/enable-reflector=yes/' "$AVAHI_CONF"
    else
        echo "enable-reflector=yes" >> "$AVAHI_CONF"
    fi
    systemctl restart avahi-daemon
    info "avahi reflector enabled (for VM mDNS resolution)"
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
if virsh net-list --all 2>/dev/null | grep -q 'default.*active'; then
    info "libvirt default network is active"
elif virsh net-list --all 2>/dev/null | grep -q 'default'; then
    warn "libvirt default network exists but is not active, starting..."
    virsh net-start default || true
    virsh net-autostart default || true
    info "libvirt default network started"
else
    warn "libvirt default network does not exist, creating..."
    if [[ -f /usr/share/libvirt/networks/default.xml ]]; then
        virsh net-define /usr/share/libvirt/networks/default.xml
        virsh net-start default
        virsh net-autostart default
        info "libvirt default network created and started"
    else
        error "Cannot find /usr/share/libvirt/networks/default.xml"
        echo "    Please create the default network manually"
    fi
fi

# --- 8b. Create bridge for VM mDNS access ---
# VMs need to be on the same L2 network as host for mDNS (.local) to work
# This creates a bridge but does NOT activate it (user must do that manually)
if nmcli connection show br0 &>/dev/null; then
    info "Bridge br0 already exists"
else
    # Find primary ethernet interface (the one currently connected)
    PRIMARY_IFACE=$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2=="ethernet" && $3=="connected" {print $1; exit}')

    if [[ -n "$PRIMARY_IFACE" ]]; then
        step "Creating bridge br0 for mDNS connectivity..."
        nmcli connection add type bridge ifname br0 con-name br0
        nmcli connection add type bridge-slave ifname "$PRIMARY_IFACE" master br0 con-name "br0-slave-$PRIMARY_IFACE"
        info "Bridge br0 created with $PRIMARY_IFACE as slave"
        warn "To activate, run: nmcli connection down 'Wired connection 1' && nmcli connection up br0"
        echo "    (This will briefly interrupt network - don't run over SSH)"
    else
        warn "Could not detect primary ethernet interface for bridge setup"
        echo "    Manually create bridge with:"
        echo "    nmcli connection add type bridge ifname br0 con-name br0"
        echo "    nmcli connection add type bridge-slave ifname <your-interface> master br0"
    fi
fi

# --- 8c. Allow QEMU to use br0 bridge ---
QEMU_BRIDGE_CONF="/etc/qemu/bridge.conf"
if [[ -f "$QEMU_BRIDGE_CONF" ]] && grep -q "allow br0" "$QEMU_BRIDGE_CONF"; then
    info "QEMU bridge ACL already allows br0"
else
    mkdir -p /etc/qemu
    echo "allow br0" >> "$QEMU_BRIDGE_CONF"
    info "Added br0 to QEMU bridge ACL"
fi

# Ensure qemu-bridge-helper has setuid (required for unprivileged bridge access)
BRIDGE_HELPER="/usr/lib/qemu/qemu-bridge-helper"
if [[ -u "$BRIDGE_HELPER" ]]; then
    info "qemu-bridge-helper has setuid bit"
else
    if [[ -f "$BRIDGE_HELPER" ]]; then
        chmod u+s "$BRIDGE_HELPER"
        info "Set setuid on qemu-bridge-helper"
    else
        warn "qemu-bridge-helper not found at $BRIDGE_HELPER"
    fi
fi

# --- 9. Check for SSH key ---
if [[ -f "${TARGET_HOME}/.ssh/id_ed25519.pub" ]] || [[ -f "${TARGET_HOME}/.ssh/id_rsa.pub" ]]; then
    info "SSH public key found (will be injected into VMs)"
else
    warn "No SSH public key found at ~/.ssh/id_ed25519.pub or ~/.ssh/id_rsa.pub"
    echo "    Generate one with: ssh-keygen -t ed25519"
fi

# --- 10. Download Debian golden image ---
VMW_GOLDEN_IMAGE="${VMW_CONFIG_DIR}/golden-image.qcow2"
DEBIAN_IMAGE_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"

if [[ -f "$VMW_GOLDEN_IMAGE" ]]; then
    info "Golden image already exists: $VMW_GOLDEN_IMAGE"
else
    step "Downloading Debian 12 cloud image..."
    if ! as_user "wget -O '$VMW_GOLDEN_IMAGE' '$DEBIAN_IMAGE_URL'"; then
        error "Failed to download Debian image"
        exit 1
    fi
    info "Downloaded golden image"

    # Resize to 20GB
    step "Resizing image to 20GB..."
    as_user "qemu-img resize '$VMW_GOLDEN_IMAGE' 20G"
    info "Golden image resized to 20GB"
fi

# --- Summary ---
step "Setup summary"
echo ""
echo "Config directory:  $VMW_CONFIG_DIR"
echo "Secrets file:      $VMW_SECRETS_FILE"
echo "Instances dir:     $VMW_INSTANCES_DIR"
echo "Golden image:      $VMW_GOLDEN_IMAGE"
echo ""
echo "Next steps:"
echo "  1. Log out and back in (if added to libvirt group)"
echo "  2. Edit $VMW_SECRETS_FILE with your API keys"
echo "  3. Run: vmw spawn /path/to/worktree"
echo ""
