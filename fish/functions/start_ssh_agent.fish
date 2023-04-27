function start_ssh_agent
    # Check if ssh-agent is already running
    if not set -q SSH_AGENT_PID
      eval (ssh-agent -c)
      set -gx SSH_AGENT_PID
      set -gx SSH_AUTH_SOCK

      # # Start ssh-agent
      # set -gx SSH_AUTH_SOCK (mktemp -u --suffix=agent.sock)
      # ssh-agent -a $SSH_AUTH_SOCK | source


      # Add your private key to the agent
      ssh-add
    end
end
