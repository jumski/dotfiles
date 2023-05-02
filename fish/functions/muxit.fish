function muxit
    set start_dir $argv[1]

    set -l selector_width 70
    set -l fzf_preview_width (math (tput cols) - $selector_width)

    if test -z "$start_dir"
        set dir_name (fd -H -t d --exec echo {//} \; --glob .git /home/jumski/Code |
            sed 's|/home/jumski/Code/||' |
            split_and_colorize |
            awk -v padding_width="$selector_width" '{printf "%" padding_width "s\n", $0}' |
            fzf --ansi --preview '/home/jumski/.dotfiles/bin/preview_readme /home/jumski/Code/{}' --preview-window right,$fzf_preview_width |
            sed 's/^ *//')

            # return if interrupted
            if test $status -eq 130
              return
            end
        set start_dir "/home/jumski/Code/$dir_name"
    end

    set start_dir (readlink -f "$start_dir")/

    if not test -d "$start_dir"
        echo "Directory '$start_dir' does not exist! Exiting."
        return 1
    end

    set session_name (basename "$start_dir" | tr -cd '[:alnum:]')

    echo "Making sure your keyboard is set up properly..."
    setup_input_devices

    start_ssh_agent

    tmux start-server
    tmux attach-session -t $session_name ||
        tmux \
            new-session -A -d -c "$start_dir" -s $session_name \;\
            rename-window -t 1 server \;\
            new-window -n bash -c "$start_dir" \;\
            new-window -n vim -c "$start_dir" \;\
            new-window -n repl -c "$start_dir" \;\
            attach-session
end
