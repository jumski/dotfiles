
function enable_conda
  if test -f /home/jumski/.asdf/installs/python/miniconda3-latest/bin/conda
      eval /home/jumski/.asdf/installs/python/miniconda3-latest/bin/conda "shell.fish" "hook" $argv | source
  end
end

