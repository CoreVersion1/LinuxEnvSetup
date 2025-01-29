#!/bin/bash
set -e

# Check if script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run this script with sudo."
    exit 1
fi

# check params
if [ $# -ne 1 ]; then
  echo "usage: sudo $(basename $0) package_name"
  echo "example: sudo $(basename $0) vim"
  exit
fi

package=$1
depends=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w" | sort -u)

if [ -z "$depends" ];then
  echo -e "invalid package name"
  exit
fi
echo -e " package [ $package ] all depends on: \n$depends\n"

# prepare dir
mkdir -p /tmp/$package-offline-packages/archives
sudo chmod 777 /tmp/$package-offline-packages/archives
# download
cd /tmp/$package-offline-packages/archives
sudo apt-get download $depends
# pack
cd /tmp
zip -rq /tmp/$package-offline-packages.zip ./$package-offline-packages
# clear
rm -rf /tmp/$package-offline-packages

echo -e "\n[info] done , package [ $package ] is placed in : \n/tmp/$package-offline-packages.zip"
echo -e "[info] use 'unzip $package-offline-packages.zip -d /tmp && sudo dpkg -i /tmp/$package-offline-packages/archives/*.deb' to install \n"
