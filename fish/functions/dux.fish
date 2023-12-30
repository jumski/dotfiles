function dux --description "Display disk usage"
  du -h --max-depth=1 $argv[1] | sort -h
end
