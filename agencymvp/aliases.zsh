alias drake="docker-compose run --user=$(id -u ${USER}):$(id -g ${USER}) rails env bundle exec rake"
alias dbe="docker-compose run --user=$(id -u ${USER}):$(id -g ${USER}) rails env bundle exec"
alias ddbredo="docker-compose run --user=$(id -u ${USER}):$(id -g ${USER}) rails env PARALLEL=4 CLEAN_SETUP=1 bundle exec rake db:drop db:create 'db:restore[/app/tmp/dump.sql]' db:migrate"
alias dpsql="docker-compose exec postgres psql -U postgres"

