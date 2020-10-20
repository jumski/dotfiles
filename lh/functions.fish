function etvrepo
  set repo_path (find ~/work/lh/* -type d -maxdepth 0 -print 2> /dev/null | fzf +m)

  muxit $repo_path
end

function lhservice
  set services_path ~/work/lh/lh-be-connected-factories/services/
  set -l service_path
  set preview_cmd "echo {}; echo ---------; cd $services_path/{}; git log -1 --shortstat --color=always ./"
  set service_name (find ~/work/lh/lh-be-connected-factories/services/* -maxdepth 0 -type d -exec basename {} \; 2>/dev/null | fzf +m --preview "$preview_cmd") &&

  muxit $services_path/$service_name
end
