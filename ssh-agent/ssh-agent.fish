# Ensure SSH_AUTH_SOCK is set for fish sessions
# This is a fallback - environment.d should set it for most cases
if test -z "$SSH_AUTH_SOCK"
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
end
