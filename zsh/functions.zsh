

mkcd()      { mkdir $1 && cd $1; }
coltree()   { tree -C $@ | less -R; }
rtfm()      { help "$@" || man "$@" || $BROWSER "http://www.google.com/search?q=$@"; }
s() { apt-cache search "$@" | sort | less; }

# creates new temp dir and opens new tmux window
scr(){
  if [ -z "$TMUX" ]; then
    echo "Please start tmux first!"
    exit 1
  fi

  local scratch_base_dir="$HOME/scratch"
  local current_date=$(date +%Y-%m-%d--%H:%M)
  local new_scratch_dir="${scratch_base_dir}/${current_date}"

  if [ -n "$1" ]; then
    local scratch_title=$( echo "$1" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local new_scratch_dir="${new_scratch_dir}--${scratch_title}"

    local window_title="scratch: ${scratch_title}"
  else
    local window_title="scratch"
  fi

  mkdir -p $new_scratch_dir
  echo ln -sf $new_scratch_dir/ $scratch_base_dir/current
  # ln -sf $new_scratch_dir/ $scratch_base_dir/current

  tmux new-window -n "$window_title" "cd ${new_scratch_dir}; bash -i"
}
cdscr() { cd ~/scratch/*$1*; }

mux-edit() {
  SESSION="$1"
  if [ "$SESSION" == "" ]; then
    SESSION=`tmux_current_session`
  fi
  vim ~/.tmuxinator/$SESSION.yml;
}

sizes() { du --max-depth=1 -h .; }
dux() { du -kchxa -d 1 . | sort -h; }

fname()     { find . -iname "*$@*"; }
ffname()    { find . -iname "*$@*" | grep -v tmp | grep -v bower_components | grep -v node_modules | grep -v public; }

drop_caches() { sudo sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches; }

list-colors() {
  for i in {0..255} ; do
    printf "\x1b[38;5;${i}mcolour${i} ";
  done
}

confirm() {
  echo -n "$@ "
  read -e answer
  for response in y Y yes YES Yes Sure sure SURE OK ok Ok t T tak Tak TAK
  do
    if [ "_$answer" == "_$response" ]
    then
      return 0
    fi
  done

  # Any answer other than the list above is considerred a "no" answer
  return 1
}

histgrep() { history | grep "$1" | sort -uh; }

cdproject() {
  if [ -n "$1" ]; then
    project_name="$1"
  fi

  if [ -d ./.git/.project_dir ]; then
    project_path="./.git/.project_dir"
  fi

  if [ -z "$project_name" ]; then
    project_name=$(basename `pwd`)
  fi

  if [ -z "$project_path" ]; then
    project_path="~/projects/$project_name"
  fi

  cd "$project_path"
}

cdwork() {
  if [ -z "$1" ]; then
    project_name=$(basename `pwd`)
  else
    project_name="$1"
  fi

  cd ~/work/$project_name
}

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

