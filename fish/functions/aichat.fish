function aichat
  if $1
    set aichat_path $1
  else
    set aichat_path (mktemp ~/Code/jumski/aichats/tempXXXXXX.aichat)
  end

  vim -c AIChat -c startinsert $aichat_path
end
