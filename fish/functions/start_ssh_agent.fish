function start_ssh_agent
  if ssh-add -l >/dev/null 2>&1 || ssh-add -L >/dev/null 2>&1
    echo "SSH agent already running and/or authenticated"
    return
  end

  eval (ssh-agent -c)
  ssh-add -t 12h # expire key so when laptop is stolen it doesn't get maliciously used

  # Export the environment variables
  set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
  set -gx SSH_AGENT_PID $SSH_AGENT_PID
end
