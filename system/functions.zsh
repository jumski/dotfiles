
function ping() {
  if [ -z "$@" ]; then
    prettyping --nolegend 8.8.8.8
  else if
    prettyping --nolegend $@
  fi
}
