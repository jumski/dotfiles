#!/bin/bash

if ! which clj 2>&1 >/dev/null; then
  pushd /tmp
    clojure_installer=linux-install-1.10.1.536.sh
    curl -O https://download.clojure.org/install/$clojure_installer
    chmod +x $clojure_installer
    sudo ./$clojure_installer
  popd
fi
