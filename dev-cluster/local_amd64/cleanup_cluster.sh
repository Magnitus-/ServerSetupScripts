#!/usr/bin/env bash

./shutdown_cluster.sh;

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    virsh undefine $VM;
done

for FILENAME in $(pwd)/disks/*; do
    if [[ "$(basename $FILENAME)" =~ ^(master|worker|lbl).*$ ]]; then
        rm -f $FILENAME;
    fi
done