## DEFAULT ALIASES
if test -x /usr/bin/dircolors
  #test -r ~/.dircolors && eval "(dircolors -b ~/.dircolors)" || eval "(dircolors -b)"
  #alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  #alias grep='grep --color=auto'
  #alias fgrep='fgrep --color=auto'
  #alias egrep='egrep --color=auto'
end

function ..
  cd ..
end

function ...
  cd ...
end

function alert
  if test $status -eq 0
    set notification_icon terminal
  else
    set notification_icon error
  end

  #notify-send --urgency=low -i $notification_icon (history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert\$//'\'')
end

function ll
  ls -alF
end
function la
  ls -A
end
function l
  ls -CF
end
function lh
  ls --color=always -lasth | less -R
end
function mkdir
  mkdir -p
end
function :w
  echo This is not vim, stupid!
end
function :wq
  echo This is not vim, stupid!
end
function :q
  confirm "Quit terminal? [Y/n]" && exit
end
function p
  pgrep -fl
end

function ack
  ack-grep
end
function agp
  ag --pager='less -R'
end

function biggest
  du -hs * | sort -h | column -t
end
function xevx
  xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
end
function humandate
  date +\"%Y-%m-%d\"
end
function prettyjson
  python -mjson.tool
end
#alias bc="bc -l"
function vi
  vim $argv
end
function path
  echo $PATH | tr ':' '\n'
end

function random_mac
 # sudo ifconfig wlan0 ether (openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//")
end
function compile_tags
  ctags -R --exclude=.git --exclude=log * $GEM_HOME/gems/*
end
