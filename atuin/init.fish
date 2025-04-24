
if status is-interactive
  # initialize starship prompt if present
  if which atuin 2>&1 >/dev/null
    atuin init fish | source
  end
end
