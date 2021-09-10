# grc overides for ls
if which gls &>/dev/null
  alias ls="gls -F --color"

  alias l="gls -lAh --color"

  alias ll="gls -l --color"

  alias la="gls -A --color"
end

alias speedtest-bytes="wget -O /dev/null http://speedtest.tele2.net/10GB.zip"
alias speedtest-bits="wget -O /dev/null http://speedtest.tele2.net/10GB.zip --report-speed=bits"

alias calc=/usr/bin/dc
