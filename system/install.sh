sudo apt install -y \
  xcape \
  vim \
  htop \
  git-core \
  tmux \
  tig \
  xclip \

which bat || (
  wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.8.0/bat-musl_0.8.0_amd64.deb
  sudo dpkg -i /tmp/bat.deb
  rm /tmp/bat.deb
)

# install theme
mkdir -p "$(bat cache --config-dir)/themes"
cd "$(bat cache --config-dir)/themes"
git clone https://github.com/jumski/Colorsublime-Themes
bat cache --init

sudo ln -sf $ZSH/bin/chrum /usr/bin/chrum
sudo chmod +x /usr/bin/chrum
