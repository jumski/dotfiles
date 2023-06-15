alias prod-heroku='heroku run --app toolchest-production'
alias stag-heroku='heroku run --app toolchest-staging'

alias rr='docker compose run web bin/rails'

alias devdb-redo='rr db:drop db:create db:environment:set db:schema:load db:migrate db:seed db:migrate:status'
alias testdb-redo='RAILS_ENV=test rr db:drop db:create db:environment:set db:schema:load db:migrate db:migrate:status'
alias db-redo='devdb-redo && testdb-redo'

alias dev-redo='docker compose build web && docker compose run web yarn install && docker compose run web bundle install && docker compose build web'
