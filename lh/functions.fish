function etvrepo
  set repo_path (find ~/work/lh/* -type d -maxdepth 0 -print 2> /dev/null | fzf +m)

  muxit $repo_path
end

function lhservice
  set services_path ~/work/lh/lh-be-connected-factories/services/
  set -l service_path
  set service_name (find ~/work/lh/lh-be-connected-factories/services/* -maxdepth 0 -type d -exec basename {} \; 2>/dev/null | fzf +m --preview "echo {}; echo ---------; ls --color=always $services_path/{}") &&

  muxit $services_path/$service_name
end
