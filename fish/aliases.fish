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

alias ..="cd .."

alias ...="cd ../.."

alias ll="ls -alF --group-directories-first"
alias la="ls -A"
alias l="ls -CF"
alias lh="ls --color=always -lasth | less -R"
#function mkdir
#  mkdir -p
#end
alias :w="echo This is not vim, stupid!"
alias :wq="echo This is not vim, stupid!"
alias :q="confirm 'Quit terminal? [Y/n]' && exit"
alias p="pgrep -fl"

#alias ack-grep=rg
#alias ack=rg
#alias ag=rg
function rgp
  rg --pretty $argv | less -R
end

alias biggest="du -hs * | sort -h | column -t"
function xevx
  xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
end
alias humandate="date +\"%Y-%m-%d\""
alias prettyjson="python -mjson.tool"
alias bc="bc -l"
alias vi=vim

alias print_path_var="echo $PATH | tr ':' '\n'"

alias compile_tags="ctags -R --exclude=.git --exclude=log * $GEM_HOME/gems/*"
