which bat || (
  wget -O /tmp/bat.deb https://github.com/sharkdp/bat/releases/download/v0.8.0/bat-musl_0.8.0_amd64.deb
  sudo dpkg -i /tmp/bat.deb
  rm /tmp/bat.deb
)

# install theme
if [ ! bat --list-themes | grep Gruvbox-N 2>&1 >/dev/null ]; then
  mkdir -p "$(bat cache --config-dir)/themes"
  cd "$(bat cache --config-dir)/themes"
  git clone https://github.com/jumski/Colorsublime-Themes
  bat cache --init
fi
