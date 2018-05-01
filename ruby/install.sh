echo Install chruby
test -f /usr/local/share/chruby/chruby.sh || {
  cd /tmp
  wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  tar -xzvf chruby-0.3.9.tar.gz
  cd chruby-0.3.9/
  sudo make install
}

echo Install chruby-default-gems
test -d ~/.chruby-default-gems || {
  git clone https://github.com/bronson/chruby-default-gems ~/.chruby-default-gems
}

echo Install ruby-install
which ruby-install || {
  cd /tmp
  wget -O ruby-install-0.6.1.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.1.tar.gz
  tar -xzvf ruby-install-0.6.1.tar.gz
  cd ruby-install-0.6.1/
  sudo make install
}

echo Install deb packages required
sudo apt install -y \
  libssl-dev \
