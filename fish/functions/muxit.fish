function process_paths
  while read -l path
    set dirname (dirname $path)
    if test "$dirname" = "."
      set dirname ""
    else
      set dirname "$dirname/"
    end
    set basename (basename $path)
    set left_half_width $argv[1]

    set dirname_length (string length $dirname)
    set basename_length (string length $basename)

    set_color grey
    printf %{$left_half_width}s $dirname
    set_color green
    echo $basename
    set_color normal
  end
end

function muxit
  set start_dir $argv[1]

  set term_width (/usr/bin/tput cols)
  # set popup_width (math -s0 "round((0.8 * $term_width) / 2) * 2")
  set popup_width 80
  set left_half_width 30
  # set left_half_width (math -s0 "round(($popup_width / 2) / 2) * 2")
  set fzf_prompt_padding (math $left_half_width + 2)
  set fzf_prompt (printf %{$fzf_prompt_padding}s "")

  if test -z "$start_dir"
    set cache_file ~/.cache/muxit-projects
    
    # Update cache if it's missing or older than 1 hour
    if not test -f $cache_file; or test (find $cache_file -mmin +60 2>/dev/null | wc -l) -gt 0
      set_color green
      echo -n "Refreshing project cache "
      set spinner_chars "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
      set spinner_index 1
      
      muxit-update-cache &
      set update_pid $last_pid
      
      while kill -0 $update_pid 2>/dev/null
        echo -en "\r\033[KRefreshing project cache $spinner_chars[$spinner_index]"
        set spinner_index (math "$spinner_index % 10 + 1")
        sleep 0.1
      end
      
      echo -e "\r\033[KRefreshing project cache ✓"
      set_color normal
    end
    
    set dir_name (
    cat $cache_file |
    process_paths $left_half_width |
    fzf --ansi --keep-right --margin=0,0 --prompt="$fzf_prompt"
    )

    if test $status -eq 130
      echo "Error in directory search!"
      return
    end

    if test -z "$dir_name"
      echo "Directory not found!"
      return
    end

    set dir_name (echo -e "$dir_name" | sed 's/^ *//')

    if test "$dir_name" = ".dotfiles"
      set start_dir "/home/jumski/$dir_name"
    else
      set start_dir "/home/jumski/Code/$dir_name"
    end
  end

  set start_dir (readlink -f "$start_dir")/

  if not test -d "$start_dir"
    echo "Directory '$start_dir' does not exist! Exiting."
    return 1
  end

  set session_name (basename "$start_dir" | tr -cd '[:alnum:]-_')


  # switch to existing session if possible to speed up the process
  if test -n "$TMUX"
    if tmux list-sessions | grep -q $session_name
      tmux switch-client -t $session_name
      return
    end
  else
    if tmux has-session -t $session_name
      tmux attach-session -t $session_name
      return
    end
  end

  echo "Making sure your keyboard is set up properly..."
  setup_input_devices

  start_ssh_agent

  if test -n "$TMUX"
    # Inside tmux
    tmux \
      new-session -d -c "$start_dir" -s $session_name \;\
      rename-window -t $session_name:1 server \;\
      new-window -n bash -c "$start_dir" -t $session_name \;\
      new-window -n vim -c "$start_dir" -t $session_name \;\
      new-window -n repl -c "$start_dir" -t $session_name
    # Switch to the new session after creating all the windows
    tmux switch-client -t $session_name
  else
    # Outside of tmux
    tmux start-server
    tmux \
      new-session -A -d -c "$start_dir" -s $session_name \;\
      rename-window -t 1 server \;\
      new-window -n bash -c "$start_dir" \;\
      new-window -n vim -c "$start_dir" \;\
      new-window -n repl -c "$start_dir" \;\
      attach-session
  end
end
