" set nocompatible               " be iMproved
filetype off                   " required!

" make sure plugins call posix shell, not fish
set shell=/bin/sh

if has('vim_starting')
  set runtimepath^=~/.vim/bundle/neobundle.vim/
endif
