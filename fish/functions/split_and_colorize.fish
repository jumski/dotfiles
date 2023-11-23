function split_and_colorize
    set -l left_color grey
    set -l right_color green

    while read -l line
      if string match -q '*/*' $line
        set parts_arr (string split / $line)
        set left_parts_arr $parts_arr[1..-2]

        set left_part (string join / $left_parts_arr)/
        set right_part (echo $parts_arr[-1])
      else
        set left_part ""
        set right_part $line
      end

      set left_part_colorized (set_color 5c5c5c; echo $left_part)
      set right_part_colorized (set_color green; echo $right_part)

      echo $left_part_colorized$right_part_colorized
    end
end
