function pry_attach
  docker attach --detach-keys="ctrl-c" (docker-compose ps | grep web-1 | awk '{print $1}')
end
