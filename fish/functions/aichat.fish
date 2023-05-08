function aichat
  set aichats_dir "/home/jumski/ObszaryOdpowiedzialnosci/Komputery i Internet/aichats"

  if test -n "$1"
    set aichat_path "$1"
  else
    read --prompt-str "Prompt > " prompt
    set slug (slugify "$prompt" | string sub -l 80)

    set aichat_path (mktemp "$aichats_dir/"{$slug}"_XXXXXX.aichat")

  end

  echo -e ">>> user\n\n" >> "$aichat_path"
  vim -c AIChat -c startinsert "$aichat_path"
end
