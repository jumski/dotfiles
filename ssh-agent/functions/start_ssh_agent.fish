# Add SSH keys to the systemd-managed ssh-agent
# The agent itself is managed by systemd user service, this just adds keys
function start_ssh_agent --argument-names skip_add_keys
    # Check if agent socket exists
    if not test -S "$SSH_AUTH_SOCK"
        echo "SSH agent socket not found at $SSH_AUTH_SOCK"
        echo "Make sure ssh-agent.service is running: systemctl --user status ssh-agent"
        return 1
    end

    if test -z "$skip_add_keys"
        # Check if keys are already loaded
        if not ssh-add -l >/dev/null 2>&1
            echo "Adding SSH keys (using agent default 12h timeout)..."
            ssh-add
        else
            echo "SSH keys already loaded"
        end
    end
end
