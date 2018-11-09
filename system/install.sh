sudo apt install -y \
  xcape \
  vim \
  htop \
  git-core \
  tmux \
  tig \
  xclip \

wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.8.0/bat-musl_0.8.0_amd64.deb
sudo dpkg -i /tmp/bat.deb
rm /tmp/bat.deb

sudo ln -sf $ZSH/bin/chrum /usr/bin/chrum
sudo chmod +x /usr/bin/chrum
