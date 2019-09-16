#!/usr/bin/env bash

source ./vars.sh;

mkdir -p $(pwd)/disks;
if [ ! -f "./disks/$DOWNLOADED_IMAGE_NAME" ]; then
    echo "Downloading source image...";
    wget $VM_IMAGE_LOCATION -O ./disks/$DOWNLOADED_IMAGE_NAME;
fi

rm -f id_rsa id_rsa.pub;
ssh-keygen -t rsa -f id_rsa -q -N "";

rm -f user-data;
sed -e "s/{{ssh_pub_key}}/$(sed 's:/:\\/:g' id_rsa.pub)/" user-data.j2 > user-data;

rm -f seed.iso;
cloud-localds seed.iso user-data meta-data;
