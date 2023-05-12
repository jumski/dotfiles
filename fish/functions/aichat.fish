function aichat
  set aichats_dir ~/aichats

  if test ! -d $aichats_dir
    echo "$aichats_dir does not exist"
    return 1
  end

  if test -n "$1"
    set aichat_path "$1"
  else
    read --prompt-str "Prompt > " prompt

    if test $status -ne 0
      echo "Exiting AIChat"
      return
    end

    set slug (slugify "$prompt" | string sub -l 80)

    set aichat_path (mktemp --tmpdir="$aichats_dir" --suffix=.aichat {$slug}_XXXXXX)
  end

  echo -e ">>> user\n\n$prompt\n\n" >> "$aichat_path"
  vim -c AIChat -c startinsert "$aichat_path"
end
