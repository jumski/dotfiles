# Source wt toolkit utilities for compatible session naming with worktrees
set -l dotfiles_root (dirname (dirname (dirname (status filename))))
set -l wt_lib "$dotfiles_root/wt/lib/common.fish"
if test -f "$wt_lib"
  source "$wt_lib"
end

# Session Naming Strategy
# =======================
# This function generates tmux session names that are:
# 1. Consistent across muxit and wt toolkit (critical for coordination)
# 2. Descriptive for human identification
# 3. Tmux-compatible (only alphanumeric, hyphens, underscores, @ symbol)
#
# Three naming cases:
#
# 1. .dotfiles (special case)
#    Input:  /home/jumski/.dotfiles/
#    Output: "dotfiles"
#    Reason: Single special repo, simple name
#
# 2. wt-managed worktrees (paths containing /worktrees/)
#    Input:  /home/jumski/Code/pgflow-dev/pgflow/worktrees/feat-auto-compile/
#    Output: "feat-auto-compile@pgflow" (via _wt_get_session_name)
#    Logic:  Uses wt toolkit's _wt_get_session_name() for compatibility
#    - Extracts worktree name: "feat-auto-compile" (basename of worktree dir)
#    - Extracts repo name: "pgflow" (basename of bare repo parent)
#    - Combines via _wt_get_session_name: "worktree@repo" format
#    Why: wt toolkit also creates sessions this way; ensures muxit and wt
#         can detect and reuse each other's sessions
#    Note: Only uses basename of repo parent to match wt's expectations
#
# 3. Regular repos in ~/Code/ hierarchy
#    Input:  /home/jumski/Code/org/repo/
#    Output: "org/repo"
#    Logic:  Extract org/repo from ~/Code/ path, keep forward slash
#    Note:   DIFFERENT from worktrees! Regular repos keep slashes,
#           worktrees remove them. This distinguishes them visually.
#
# Fallback: Any other path uses basename only
#
# Important: Session naming rules are enforced by tmux:
# - Use "=$session_name" in has-session/switch-client to avoid partial matches
#   (prevents "main" from matching "main@repo")

function _muxit_get_session_name
  set -l start_dir $argv[1]
  set -l session_name

  # Calculate session name based on directory structure
  if string match -q "*/.dotfiles/*" "$start_dir"; or string match -q "*/.dotfiles" "$start_dir"
    # Special case for .dotfiles
    set session_name "dotfiles"
  else if string match -q "*/worktrees/*" "$start_dir"
    # wt-managed worktree: use wt's session naming convention
    set -l worktree_name (basename "$start_dir")

    # Get parent path and extract just the repo name (last component)
    # e.g., /home/jumski/Code/pgflow-dev/pgflow/worktrees/feat -> pgflow
    set -l parent_path (string replace -r '/worktrees/[^/]+/?$' '' "$start_dir")
    set -l repo_name (basename "$parent_path")

    # Use wt's session naming function if available for proper sanitization
    if type -q _wt_get_session_name
      set session_name (_wt_get_session_name "$worktree_name" "$repo_name")
    else
      # Fallback: manual construction matching wt's sanitization rules
      set session_name "$worktree_name@$repo_name"
      set session_name (echo $session_name | tr -cd '[:alnum:]-_@')
    end
  else if string match -q "*/Code/*" "$start_dir"
    # Regular repo: Extract org/repo from ~/Code/org/repo structure
    set -l code_path (string replace -r '.*/Code/' '' "$start_dir")
    set -l code_path (string trim -r -c '/' "$code_path")  # Remove trailing slash

    # Count path components
    set -l parts (string split '/' "$code_path")

    if test (count $parts) -ge 2
      # Has org/repo structure - use org/repo format
      set session_name "$parts[1]/$parts[2]"
    else
      # Just repo name
      set session_name "$parts[1]"
    end

    # Sanitize: keep alphanumeric, hyphens, underscores, and forward slashes
    set session_name (echo $session_name | tr -cd '[:alnum:]-_/')
  else
    # Fallback: just use basename
    set session_name (basename "$start_dir" | tr -cd '[:alnum:]-_')
  end

  echo $session_name
end

function _calculate_max_dirname_length
  set max_length 0
  while read -l path
    set dirname (dirname $path)
    if test "$dirname" = "."
      set dirname ""
    else
      set dirname "$dirname/"
    end
    set dirname_length (string length $dirname)
    if test $dirname_length -gt $max_length
      set max_length $dirname_length
    end
  end
  echo $max_length
end

function _process_paths
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

    # Calculate dynamic left_half_width based on longest dirname + 5
    set max_dirname_length (cat $cache_file | _calculate_max_dirname_length)
    set left_half_width (math $max_dirname_length + 5)
    set fzf_prompt_padding (math $left_half_width + 2)
    set fzf_prompt (printf %{$fzf_prompt_padding}s "")

    set dir_name (
    cat $cache_file |
    _process_paths $left_half_width |
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

  set session_name (_muxit_get_session_name "$start_dir")

  # switch to existing session if possible to speed up the process
  # Use exact matching with = prefix to prevent partial matches (e.g., "main" matching "main@repo")
  if test -n "$TMUX"
    if tmux has-session -t "=$session_name" 2>/dev/null
      tmux switch-client -t $session_name
      return
    end
  else
    if tmux has-session -t "=$session_name" 2>/dev/null
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
