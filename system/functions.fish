
function ping
  if test -z $argv
    prettyping --nolegend 8.8.8.8
  else
    prettyping --nolegend $argv
  end
end

function coltree
  tree -C $argv | less -R
end
