#!/bin/bash

which asdf 2>/dev/null 1>/dev/null || {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.1
}

