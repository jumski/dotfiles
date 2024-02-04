if which mcfly 2>&1 >/dev/null
  set -gx MCFLY_INTERFACE_VIEW BOTTOM
  mcfly init fish | source
end
