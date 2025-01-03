function encode_special_chars
  echo "$argv[1]" | jq -sRr @uri
end
