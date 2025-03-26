function start_ssh_agent --argument-names skip_add_keys
  # Path to store SSH agent socket and PID information
  set -l ssh_env_file "$HOME/.ssh/agent.env"
  
  function __start_new_agent
    echo "Starting new SSH agent..."
    # Start a new agent and capture its environment
    ssh-agent -c | sed 's/^echo/#echo/' > $ssh_env_file
    chmod 600 $ssh_env_file
    source $ssh_env_file
    
    # Add keys with timeout unless explicitly skipped
    if test -z "$skip_add_keys"
      echo "Adding SSH keys with 12-hour timeout..."
      ssh-add -t 12h # expire key so when laptop is stolen it doesn't get maliciously used
    else
      echo "Skipping automatic key addition as requested"
    end
    
    # Save to tmux environment if we're in tmux
    if test -n "$TMUX"
      tmux setenv -g SSH_AUTH_SOCK $SSH_AUTH_SOCK
      tmux setenv -g SSH_AGENT_PID $SSH_AGENT_PID
    end
  end
  
  # Try to load existing agent info
  if test -f $ssh_env_file
    source $ssh_env_file > /dev/null
  end
  
  # Check if agent is still running with our keys
  if test -n "$SSH_AGENT_PID" && ps -p $SSH_AGENT_PID > /dev/null
    # Agent is running, but check if it has our keys
    if not ssh-add -l > /dev/null 2>&1
      echo "SSH agent running but no keys loaded."
      if test -z "$skip_add_keys"
        echo "Adding keys with 12-hour timeout..."
        ssh-add -t 12h
      else
        echo "Skipping automatic key addition as requested"
      end
    else
      echo "SSH agent already running with keys loaded"
    end
  else
    # No agent running or PID not found, start a new one
    __start_new_agent
  end
  
  # Export the environment variables globally
  set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
  set -gx SSH_AGENT_PID $SSH_AGENT_PID
  
  # Update tmux environment if we're in tmux
  if test -n "$TMUX"
    tmux setenv -g SSH_AUTH_SOCK $SSH_AUTH_SOCK
    tmux setenv -g SSH_AGENT_PID $SSH_AGENT_PID
  end
end
