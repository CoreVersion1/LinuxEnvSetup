#!/bin/bash
sudo apt update
sudo apt upgrade -y

# basic tools
sudo apt install -y \
net-tools \
unzip \
vim \
mlocate \
tree \
tmux

# develop depenencies
sudo apt install -y \
git \
cmake \
cmake-curses-gui \
pigpio \
libgoogle-glog-dev
