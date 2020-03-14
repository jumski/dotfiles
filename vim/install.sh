curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if which yarn 2>&1 >/dev/null; then
  yarn global add instant-markdown-d
fi
