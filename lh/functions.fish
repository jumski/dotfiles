function etvrepo
  set query $argv[1]
  set repos_path ~/work/lh/
  set repo_name (find $repos_path -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | fzf +m --query "$query")

  muxit $repos_path/$repo_name
end

function lhservice
  set query $argv[1]
  set services_path ~/work/lh/lh-be-connected-factories/services/
  set -l service_path
  set preview_cmd "echo {}; echo ---------; cd $services_path/{}; git log -1 --shortstat --color=always ./"
  set service_name (find $services_path -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | fzf +m --query "$query" --preview "$preview_cmd") &&

  muxit $services_path/$service_name
end

function lhdc --wraps "docker-compose"
  set config_flags

  if test -f docker-compose.yml
    set config_flags -f docker-compose.yml
  end

  if test -f docker-compose.app.yml
    set config_flags $config_flags -f docker-compose.app.yml
  end

  if test -f docker-compose.services.yml
    set config_flags $config_flags -f docker-compose.services.yml
  end

  docker-compose $config_flags $argv
end
