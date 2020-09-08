#!/bin/bash

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jumski
