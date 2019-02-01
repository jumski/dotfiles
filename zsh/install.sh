# install colorscheme
mkdir -p ~/installed
if [ ! -d ~/installed/base16-gruvbox ]; then
  git clone git://github.com:jumski/base16-gruvbox.git ~/installed/base16-gruvbox

  cd ~/installed/base16-gruvbox/gnome-terminal
  chmod +x ./base16-gruvbox.dark.sh
  ./base16-gruvbox.dark.sh
fi

# install monaco-nerd-fonts
if [ ! -d ~/installed/monaco-nerd-fonts ]; then
  git clone  https://github.com/Karmenzind/monaco-nerd-fonts ~/installed/monaco-nerd-fonts
  sudo mkdir -p /usr/share/fonts/monaco-nerd-fonts
  sudo cp ~/installed/monaco-nerd-fonts/fonts/* /usr/share/fonts/monaco-nerd-fonts
  sudo fc-cache -fv
fi

# change shell for current user
sudo chsh -s $(which zsh) jumski
