## Run application/stop application
alias lhu="docker-compose -f docker-compose.yml -f docker-compose.app.yml up"
alias lhd="docker-compose -f docker-compose.yml -f docker-compose.app.yml down --remove-orphans"

## Force rebuild
alias lhr="docker-compose -f docker-compose.yml -f docker-compose.app.yml down --rmi local"

## Same as above, but also run all services this service depends on
alias lhus="docker-compose -f docker-compose.yml -f docker-compose.app.yml -f docker-compose.services.yml up"
alias lhds="docker-compose -f docker-compose.yml -f docker-compose.app.yml -f docker-compose.services.yml down --remove-orphans"

# rebuild
alias lhb="docker-compose -f docker-compose.yml -f docker-compose.app.yml build"

# attach bash shell to first running docker container (the app)
function lhe
  if set -q argv[1]
    set command $argv
  else
    set command /bin/bash
  end

  docker exec -it (docker ps | grep -m 1 start_docker | awk '{print $1}') $command
end


function lhx
  if set -q argv[1]
    set command $argv
  else
    set command /bin/bash
  end

  docker exec -it -u (id -u):(id -g) (docker ps | grep -m 1 start_docker | awk '{print $1}') $command
end

