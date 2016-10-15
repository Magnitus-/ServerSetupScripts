#!/bin/bash
#Adapted directly from the official installation instructions

if [ "$(whoami)" != "root" ]; then
    echo "This script requires root privileges";
    exit 1;
fi

#Installing docker-engine
apt-get update;
apt-get install -y apt-transport-https ca-certificates;
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D;
touch /etc/apt/sources.list.d/docker.list;
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list;
apt-get update;
apt-get purge lxc-docker;
apt-get install -y linux-image-extra-$(uname -r);
apt-get install -y docker-engine;
systemctl start docker;
systemctl enable docker;


#Installing docker-compose
apt-get install -y curl;
curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose;
chmod +x /usr/local/bin/docker-compose;
