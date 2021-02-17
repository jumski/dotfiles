
function lh_prompt
  set -l yellow (set_color -o yellow)
  set -l red (set_color -o red)
  set -l green (set_color -o green)
  set -l normal (set_color normal)

  # set color for kubectx, but only for ~/work/lh repos
  if pwd | grep work/lh &>/dev/null
    set kubectx_env (which kubectx &>/dev/null && kubectx --current)
    switch $kubectx_env
      case lh_production
        set kubectx_color $red
      case lh_test
        set kubectx_color $yellow
      case lh_staging
        set kubectx_color $green
    end

    echo -n -s "$kubectx_color [$kubectx_env] $normal"
  end
end
