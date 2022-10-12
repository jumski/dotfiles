
function alert
  if test $status -eq 0
    set notification_icon terminal
  else
    set notification_icon error
  end

  notify-send --urgency=low -i $notification_icon (history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert\$//'\'')
end
