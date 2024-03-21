
function ollama
  set given_value 'jumski-manjaro-pc'

  if test (hostname) = $given_value
    echo Run Ollama locally
    docker compose --file ~/Code/jumski/devmachine-stacks/ollama/compose.yaml exec ollama ollama $argv
  else
    echo Run Ollama via SSH to $given_value
    ssh pc docker compose --file ~/Code/jumski/devmachine-stacks/ollama/compose.yaml exec ollama ollama $argv
  end
end
