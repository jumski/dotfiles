
function mkcd
  mkdir $1 && cd $1
end

function coltree
  tree -C $argv | less -R
end

# creates new temp dir and opens new tmux window
function scr
  if test -z $TMUX
    echo "Please start tmux first!"
    exit 1
  end

  set scratch_base_dir $HOME/scratch
  set current_date (date +%Y-%m-%d--%H:%M)
  set new_scratch_dir "$scratch_base_dir"/"$current_date"

  if test -n $1
    set scratch_title (echo $1 | sed 's/[^a-zA-Z0-9_-]/_/g')
    set new_scratch_dir "$new_scratch_dir"--"$scratch_title"

    set window_title "scratch: $scratch_title"
  else
    set window_title "scratch"
  end

  mkdir -p $new_scratch_dir
  echo ln -sf $new_scratch_dir/ $scratch_base_dir/current
  # ln -sf $new_scratch_dir/ $scratch_base_dir/current

  tmux new-window -n "$window_title" "cd $new_scratch_dir; bash -i"
end
function cdscr
  cd ~/scratch/*$1*
end

function mux-edit
  set SESSION $1
  if test $SESSION -eq ""
    set SESSION (tmux_current_session)
  end
  vim ~/.tmuxinator/$SESSION.yml;
end

function sizes
  du --max-depth=1 -h .
end
function dux
  du -kchxa -d 1 . | sort -h
end

function fname
  find . -iname "*$argv*"
end
function ffname
  find . -iname "*$argv*" | grep -v tmp | grep -v bower_components | grep -v node_modules | grep -v public
end

function drop_caches
  sudo sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches
end

function list_colors
  for i in {0..255}
    #printf \x1b[38;5;"$i"mcolour"$i"
  end
end

function confirm
  echo -n "$argv "
  read -e answer
  for response in y Y yes YES Yes Sure sure SURE OK ok Ok t T tak Tak TAK
    if test "_$answer" -eq "_$response"
      return 0
    end
  end

  # Any answer other than the list above is considerred a "no" answer
  return 1
end

function histgrep
  history | grep $1 | sort -uh
end

function cdproject
  if test -n $1
    set project_name $1
  end

  if test -z $project_name
    set project_name (basename (pwd))
  end

  cd ~/Dropbox/projects/"$project_name"/
end

function cdwork
  if test -z $1
    set project_name (basename (pwd))
  else
    set project_name $1
  end

  cd ~/work/$project_name
end

# repeat() {
#   n=$1
#   i=0
#   shift

#   echo "Repeating \`$@\` $n times"
#   echo

#   while [ $(( i += 1 )) -le $n ]
#   do
#     echo "= Run #$i ($@)"
#     eval "$@"
#   done
# }
# loop() {
#   i=0

#   echo "Looping \`$@\`"
#   echo

#   while true; do
#     i=$((i += 1 ))
#     echo "= Iteration #$i ($@)"
#     eval "$@"
#   done
# }
# retry() {
#   while ! "$@"; do sleep 1; done
# }

