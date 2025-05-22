# function alert
#     set -l last_cmd (history --max=2 | tail -n 1)
#     set -l last_status $status
#     set -l notif_text $argv
#     if test -z "$notif_text"
#         set notif_text "Command finished: $last_cmd"
#     end
#     notify-send "Exit Status: $last_status" "$notif_text"
# end

function alert
    set -l last_status $status
    set -l last_cmd (history --max=2 | tail -n 1)
    set -l notif_text $argv
    if test -z "$notif_text"
        set notif_text "Command finished: $last_cmd"
    end
    if test "$last_status" -eq 0
        notify-send --icon=dialog-positive "Success (Exit: $last_status)" "$notif_text"
    else
        notify-send --icon=dialog-error "Failed (Exit: $last_status)" "$notif_text"
    end
end
# function alert
#   if test $status -eq 0
#     set notification_icon terminal
#   else
#     set notification_icon error
#   end

#   notify-send --urgency=low -i $notification_icon (history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert\$//'\'')
# end
