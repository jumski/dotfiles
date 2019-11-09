alias docker_rake="docker-compose run rails env PARALLEL=10 CLEAN_SETUP=1 bundle exec rake"
alias docker_dbredo="docker_rake db:drop db:create 'db:restore[/app/tmp/dump.sql]' db:migrate"

