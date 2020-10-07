function etvrepo
  set repo_path (find ~/work/lh/* -type d -maxdepth 0 -print 2> /dev/null | fzf +m)

  muxit $repo_path
end

function lhservice
  set -l service_path
  set service_path (find ~/work/lh/lh-be-connected-factories/services/* -type d -maxdepth 0 -print 2> /dev/null | fzf +m) &&
  muxit $service_path
end
