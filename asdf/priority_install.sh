#!/bin/bash

which asdf 2>/dev/null 1>/dev/null || {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.1
}

source ~/.asdf/asdf.sh

# Install all asdf plugins
for plugin_name in $(cut -d' ' -f1 tool-versions.symlink | tr '\n' ' '); do
  asdf plugin add $plugin_name
done

asdf update
asdf plugin update --all

# make sure we have top-level .tool-versions linked
ln --force `realpath tool-versions.symlink` $HOME/.tool-versions

# install all versions from tool-versions.symlink
asdf install
