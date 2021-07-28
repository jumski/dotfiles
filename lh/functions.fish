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

function lh-consume
  set metrics_pod (kubectl get pods | grep metrics | grep Running | awk '{print $1}' | head -1)

  set topic $argv[1]
  # set offset '-1'
  # set partition '0'
  # set flags "-t $topic -o $offset -p $partition"
  set command "kafkacat -b \$KAFKA_BROKERS -C -t $topic $flags -e -D '' -f %s\\n | ruby -rjson -rmsgpack -n -e 'puts \$_'"
  # set command "kafkacat -b \$KAFKA_BROKERS -C $flags -e -D '' -f %s\\n | ruby -rjson -rmsgpack -n -e 'puts JSON.dump(MessagePack.unpack(\$_[0..-2]))'"
  # set command time

  kubectl exec -it $metrics_pod -- sh -c $command
end
