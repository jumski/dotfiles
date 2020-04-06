#!/bin/bash

# install graalvm
if ! which gu 2>&1 >/dev/null; then
  release_url=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-20.0.0/graalvm-ce-java11-linux-amd64-20.0.0.tar.gz
  pkg_file=/tmp/graalvm.tar.gz
  dir_name=$(basename --suffix .tar.gz ${pkg_file})

  wget -O ${pkg_file} "${release_url}"

  cd /tmp
  tar -xvzf ${pkg_file}
  mkdir -p ~/installed
  mv /tmp/graalvm-ce-java11-20.0.0 ~/installed/graalvm
fi

# install native-image
if ! gu list native-image | grep native-image 2>&1 >/dev/null; then
  gu install native-image
fi

