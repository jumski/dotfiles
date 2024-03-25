
if status is-interactive
  # initialize starship prompt if present
  if which starship 2>&1 >/dev/null
    starship init fish | source
    starship completions fish | source
  end
end
