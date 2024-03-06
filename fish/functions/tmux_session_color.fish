
function tmux_session_color -a session_name
    # Define the path to the color file
    set color_file ~/.tmux_session_colors

    # Check if the color file exists, if not, create it
    if not test -f $color_file
        touch $color_file
    end

    # Check if the session_name already has an associated color
    set color (grep "^$session_name:" $color_file | cut -d':' -f2)

    # If a color is found, print it
    if set -q color[1]
        printf '%s\n' $color
    else
        # Generate a new color code (e.g., using a hash of the session name)
        set new_color (echo $session_name | cksum | awk '{printf "#%06x", $1 % (256*256*256)}')

        # Save the new color code to the color file
        echo "$session_name:$new_color" >> $color_file

        # Print the new color code
        printf '%s\n' $new_color
    end
end

# function tmux_session_color -a session_name
#     # Define the path to the color file
#     set color_file ~/.tmux_session_colors
#
#     # Check if the color file exists, if not, create it
#     if not test -f $color_file
#         touch $color_file
#     end
#
#     # Check if the session_name already has an associated color
#     set color (grep "^$session_name:" $color_file | cut -d':' -f2)
#
#     # If a color is found, print it
#     if set -q color[1]
#         printf '%s\n' $color
#     else
#         # Generate a new color code (e.g., using a hash of the session name)
#         set new_color (echo $session_name | cksum | awk '{print $1 % 256}')
#
#         # Save the new color code to the color file
#         echo "$session_name:$new_color" >> $color_file
#
#         # Print the new color code
#         printf '%s\n' $new_color
#     end
# end
