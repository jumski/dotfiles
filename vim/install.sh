#!bin/bash

if ! test -f $HOME/.local/share/nvim/site/autoload/plug.vim; then
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

if which yarn 2>&1 >/dev/null; then
  yarn global add instant-markdown-d
fi
