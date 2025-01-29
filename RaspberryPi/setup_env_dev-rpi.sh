#!/bin/bash
set -e

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run this script with sudo."
    exit 1
fi

sudo apt update
sudo apt upgrade -y

# basic tools
sudo apt install -y \
  net-tools \
  zip \
  unzip \
  vim \
  mlocate \
  tree \
  tmux

# develop depenencies
sudo apt install -y \
  git \
  make \
  cmake \
  pigpio
