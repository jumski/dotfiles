# run application/stop application
alias lhu="docker-compose -f docker-compose.yml -f docker-compose.app.yml up"
alias lhd="docker-compose -f docker-compose.yml -f docker-compose.app.yml down"

# same as above, but also run all services this service depends on
alias lhus="docker-compose -f docker-compose.yml -f docker-compose.app.yml -f docker-compose.services.yml up"
alias lhds="docker-compose -f docker-compose.yml -f docker-compose.app.yml -f docker-compose.services.yml down"

# attach bash shell to first running docker container (the app)
function lhe
    docker exec -it  (docker ps | grep -m 1 start_docker | awk '{print $1}') /bin/bash
end