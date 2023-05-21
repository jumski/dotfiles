function testdb_redo
  docker compose run web rails db:migrate:redo
  docker compose run -e RAILS_ENV=test web rails db:drop db:create db:environment:set
end
