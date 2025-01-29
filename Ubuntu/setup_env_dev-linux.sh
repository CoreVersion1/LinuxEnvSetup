#!/bin/bash
set -e

sudo apt-get update
sudo apt-get upgrade -y

# basic tools
sudo apt-get install -y \
  net-tools \
  unzip \
  mlocate \
  tree \
  tmux

# develop depenencies
sudo apt-get install -y \
  git \
  make \
  cmake \
  build-essential \
  gdb
