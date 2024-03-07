
function ollama
  docker compose --file $HOME/Code/jumski/devmachine-stacks/ollama/compose.yaml exec ollama ollama $argv
end
