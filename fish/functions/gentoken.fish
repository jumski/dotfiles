function gentoken
  if test -n $argv[1]
    set prefix "$argv[1]-"
  end

  set bytes_num $argv[2]
  if test -z $bytes_num
    set bytes_num 48
  end

  set openssl_bytes_num (math "4 * $bytes_num")

  set token (openssl rand -base64 $openssl_bytes_num | tr -dc 'a-zA-Z0-9' | head -c $bytes_num)

  echo -e "$prefix$token" | xclip -selection clipboard
  echo "$prefix$token"
end
