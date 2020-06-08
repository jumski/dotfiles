alias mux=tmuxinator

function mxf
  set preview_cmd 'bat --number --paging=never --color=always /home/jumski/.tmuxinator/{}.yml'
  set project_name (
    ls ~/.tmuxinator/*.yml |
    xargs -L1 basename -s .yml |
    fzf --ansi -d 15 --preview="$preview_cmd"
  )

  tmuxinator $project_name
end


