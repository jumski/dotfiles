alias mux=tmuxinator

function mxf() {
  local preview_cmd='bat --number --paging=never --color=always /home/jumski/.tmuxinator/{}.yml'
  local project_name=$(
    ls ~/.tmuxinator/*.yml |
    xargs -L1 basename -s .yml |
    fzf --ansi -d 15 --preview="$preview_cmd"
  )

  tmuxinator $project_name
}


