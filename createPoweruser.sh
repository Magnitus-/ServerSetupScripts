#!/bin/bash
if [ "$(whoami)" != "root" ]; then
    echo "This script requires root privileges";
    exit 1;
fi
useradd $1 -s /bin/bash -m;
echo "Input password for ${1}: ";
read password;
echo ${1}:$password | chpasswd;
echo "${1} ALL=(ALL:ALL) ALL" >> /etc/sudoers;
