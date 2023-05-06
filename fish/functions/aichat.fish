function aichat
  if test -n "$1"
    set aichat_path "$1"
  else
    set aichat_path (mktemp ~/Code/jumski/aichats/tempXXXXXX.aichat)
  end

  echo -e ">>> user\n\n" >> "$aichat_path"
  read --prompt-str "Prompt > " >> "$aichat_path"
  vim -c AIChat -c startinsert "$aichat_path"
end
