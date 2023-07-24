alias prod-heroku='heroku run --app toolchest-production'
alias stag-heroku='heroku run --app toolchest-staging'

function rr --wraps='__fish_complete_path' --description 'docker compose run web bin/rails'
  docker compose run web bin/rails $argv
end

alias devdb-redo='rr db:drop db:create db:environment:set db:schema:load db:migrate db:seed db:migrate:status'
alias testdb-redo='docker compose run -e RAILS_ENV=test web bin/rails db:drop db:create db:environment:set db:schema:load db:migrate db:migrate:status'
alias db-redo='devdb-redo && testdb-redo'

alias dev-redo='docker compose build web && docker compose run web yarn install && docker compose run web bundle install && docker compose build web'

alias full-redo='dev-redo && db-redo'


# function deploy-branch-on-staging --wraps 'git branch' --description 'git push heroku-staging && db migrate'
function deploy-branch-on-staging
  set branch $argv[1]

  if git branch -a | grep -E "^\s*\b{$branch}\b"
    echo git push heroku-staging $branch:master
    echo heroku run --app toolchest-staging bin/rails db:migrate db:migrate:status
  end
end
