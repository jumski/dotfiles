function aichat
  set aichats_dir "/home/jumski/ObszaryOdpowiedzialnosci/Komputery i Internet/aichats"

  if test -n "$1"
    set aichat_path "$1"
  else
    set aichat_path (mktemp "$aichats_dir/tempXXXXXX.aichat")
  end

  echo -e ">>> user\n\n" >> "$aichat_path"
  read --prompt-str "Prompt > " >> "$aichat_path"
  vim -c AIChat -c startinsert "$aichat_path"
end
