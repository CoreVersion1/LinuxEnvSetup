#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y

# basic tools
sudo apt-get install -y \
net-tools \
unzip \
vim \
mlocate \
tree \
tmux

# develop depenencies
sudo apt-get install -y \
git \
cmake \
cmake-curses-gui \
build-essential \
gdb
