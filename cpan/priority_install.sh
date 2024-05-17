#!/bin/bash

# make sure `git add -p` can be accepted with single keypress
if perl -MTerm::ReadKey -e '' 2>/dev/null; then
  echo "Term::ReadKey is already installed."
else
  echo "Term::ReadKey is not installed, installing now..."
  sudo PERL_MM_USE_DEFAULT=1 PERL_AUTOINSTALL=--alldeps cpan -T Term::ReadKey
fi
