#!/bin/bash

if diff /etc/security/faillock.conf faillock/faillock.conf; then
  echo "faillock.conf already installed"
else
  echo "installing faillock.conf"
  sudo cp faillock/faillock.conf /etc/security/faillock.conf
fi
