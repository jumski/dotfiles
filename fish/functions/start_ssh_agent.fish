function echo_debug
  set_color 777777
  # echo "[DEBUG] $argv"
  set_color normal
end

function start_ssh_agent --argument-names skip_add_keys
  # Path to store SSH agent socket and PID information
  set -g ssh_env_file "$HOME/.ssh/agent.env"
  echo_debug "SSH env file path: $ssh_env_file"
  echo_debug "HOME value: $HOME"

  # Check if variable is empty
  if test -z "$ssh_env_file"
    echo_debug "ERROR: ssh_env_file variable is empty!"
    set ssh_env_file "$HOME/.ssh/agent.env"
    echo_debug "Reset ssh_env_file to: $ssh_env_file"
  end

  # Check if .ssh directory exists
  if not test -d "$HOME/.ssh"
    echo_debug ".ssh directory doesn't exist, creating it..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  else
    echo_debug ".ssh directory exists"
  end

  function __start_new_agent
    echo "Starting new SSH agent..."
    # echo_debug "ssh_env_file value inside function: $ssh_env_file"

    # Ensure we have a valid path
    if test -z "$ssh_env_file"
      echo_debug "ERROR: ssh_env_file is empty in __start_new_agent function!"
      set ssh_env_file "$HOME/.ssh/agent.env"
      echo_debug "Reset ssh_env_file to: $ssh_env_file"
    end
    # Start a new agent and capture its environment
    # In fish, we need to use a different approach for redirection
    echo "Running ssh-agent command..."
    set -l agent_output (ssh-agent -c | sed 's/^echo/#echo/')
    echo_debug "Agent output captured, lines: "(count $agent_output)

    echo_debug "Writing to $ssh_env_file"
    # In fish, we need to handle redirection differently
    echo_debug "Agent output content: $agent_output"
    # Use a different approach to write to the file
    printf "%s\n" $agent_output > $ssh_env_file

    echo_debug "Setting permissions on env file"
    chmod 600 "$ssh_env_file"

    echo_debug "Sourcing env file"
    source "$ssh_env_file"

    echo_debug "After sourcing, AUTH_SOCK: $SSH_AUTH_SOCK, AGENT_PID: $SSH_AGENT_PID"

    # Add keys with timeout unless explicitly skipped
    if test -z "$skip_add_keys"
      echo_debug "Adding SSH keys with 12-hour timeout..."
      ssh-add -t 12h # expire key so when laptop is stolen it doesn't get maliciously used
    else
      echo_debug "Skipping automatic key addition as requested"
    end

    # Save to tmux environment if we're in tmux
    if test -n "$TMUX"
      echo_debug "In tmux session, setting tmux environment variables"
      tmux setenv -g SSH_AUTH_SOCK $SSH_AUTH_SOCK
      tmux setenv -g SSH_AGENT_PID $SSH_AGENT_PID
    else
      echo_debug "Not in tmux session"
    end
  end

  # Try to load existing agent info
  if test -f "$ssh_env_file"
    echo_debug "Found existing SSH env file, sourcing it"
    source "$ssh_env_file" > /dev/null
    echo_debug "After sourcing existing env file, AUTH_SOCK: $SSH_AUTH_SOCK, AGENT_PID: $SSH_AGENT_PID"
  else
    echo_debug "No existing SSH env file found"
  end

  # Check if agent is still running with our keys
  if test -n "$SSH_AGENT_PID"
    echo_debug "Found SSH_AGENT_PID: $SSH_AGENT_PID"
    if ps -p $SSH_AGENT_PID > /dev/null
      echo_debug "SSH agent process is running"
      # Agent is running, but check if it has our keys
      echo_debug "Checking for loaded keys..."
      if not ssh-add -l > /dev/null 2>&1
        echo_debug "SSH agent running but no keys loaded."
        if test -z "$skip_add_keys"
          echo_debug "Adding keys with 12-hour timeout..."
          ssh-add -t 12h
        else
          echo_debug "Skipping automatic key addition as requested"
        end
      else
        echo_debug "SSH agent already running with keys loaded"
      end
    else
      echo_debug "SSH agent process not found despite having PID"
      # PID exists but process not running, start a new one
      __start_new_agent
    end
  else
    echo_debug "No SSH_AGENT_PID found, starting new agent"
    # No agent running or PID not found, start a new one
    __start_new_agent
  end

  echo_debug "Final environment: AUTH_SOCK: $SSH_AUTH_SOCK, AGENT_PID: $SSH_AGENT_PID"

  # Export the environment variables globally
  set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
  set -gx SSH_AGENT_PID $SSH_AGENT_PID
  echo_debug "Environment variables exported globally"

  # Update tmux environment if we're in tmux
  if test -n "$TMUX"
    echo_debug "Updating tmux environment variables"
    tmux setenv -g SSH_AUTH_SOCK $SSH_AUTH_SOCK
    tmux setenv -g SSH_AGENT_PID $SSH_AGENT_PID
  else
    echo_debug "Not in tmux, skipping tmux environment update"
  end
end
