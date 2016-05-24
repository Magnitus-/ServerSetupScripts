#!/bin/bash
if [ -z "$1" ]
  then
    echo "Username of new user is required as an argument";
    exit 1;
fi
if [ "$(whoami)" != "root" ]; then
    echo "This script requires root privileges";
    exit 1;
fi
useradd $1 -s /bin/bash -m;
echo "Input password for ${1}: ";
read password;
echo ${1}:$password | chpasswd;
echo "${1} ALL=(ALL:ALL) ALL" >> /etc/sudoers;
