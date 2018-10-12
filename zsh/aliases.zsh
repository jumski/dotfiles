alias reload!='. ~/.zshrc'

## DEFAULT ALIASES
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias cls='clear' # Good 'ol Clear Screen command

alias ip='ip --color'
alias ipb='ip --color --brief'

alias ..='cd ..'
alias ...='cd ...'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls --color=always -lasth | less -R'
alias mkdir='mkdir -p'
alias :w='echo This is not vim, stupid!'
alias :wq='echo This is not vim, stupid!'
alias :q='confirm "Quit terminal? [Y/n]" && exit'
alias p='pgrep -fl'

alias ack=ack-grep
alias agp="ag --pager='less -R'"

alias parallel="parallel --gnu"
alias biggest="du -hs * | sort -h | column -t"
alias xevx="xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'"
alias humandate="date +\"%Y-%m-%d\""
alias prettyjson="python -mjson.tool"
alias bc="bc -l"
alias vi=vim
alias path="echo $PATH | tr ':' '\n'"

alias random_mac='sudo ifconfig wlan0 ether `openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"`'
alias compile_tags="ctags -R --exclude=.git --exclude=log * $GEM_HOME/gems/*"
