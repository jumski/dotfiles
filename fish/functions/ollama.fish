
function ollama
  set given_value 'jumski-manjaro-pc'

  if test (hostname) = $given_value
    echo run locally
    # docker compose --file ~/Code/jumski/devmachine-stacks/ollama/compose.yaml exec ollama ollama $argv
  else
    echo run via ssh
    # ssh pc docker compose --file ~/Code/jumski/devmachine-stacks/ollama/compose.yaml exec ollama ollama $argv
  end
end
