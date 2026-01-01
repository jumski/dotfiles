# Set GOPATH and add Go binaries to PATH
# Go installs packages to $GOPATH/bin (default: ~/go/bin)
set -gx GOPATH $HOME/go
fish_add_path --prepend $GOPATH/bin
