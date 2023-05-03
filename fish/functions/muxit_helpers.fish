function process_paths
    while read -l path
        set dirname (dirname $path)
        if test "$dirname" = "."
          set dirname ""
        else
          set dirname "$dirname/"
        end
        set basename (basename $path)
        set term_width (/usr/bin/tput cols)
        set left_half_width (math -s0 "$term_width / 2 - 10")

        set dirname_length (string length $dirname)
        set basename_length (string length $basename)

        set_color grey
        printf "%38s" $dirname
        set_color green
        echo $basename
        set_color normal
    end
end
