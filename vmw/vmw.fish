# vmw - VM Worktree Manager
# Run Claude Code with --dangerously-skip-permissions safely inside KVM VMs

# Config paths
set -gx VMW_CONFIG_DIR ~/.config/vmw
set -gx VMW_SECRETS_FILE $VMW_CONFIG_DIR/secrets.env
set -gx VMW_GOLDEN_IMAGE $VMW_CONFIG_DIR/golden-image.qcow2
set -gx VMW_INSTANCES_DIR $VMW_CONFIG_DIR/instances
