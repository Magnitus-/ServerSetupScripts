#!/usr/bin/env bash

MASTER0=$(virsh list --name --all | grep master0)

if [ -z "$MASTER0" ]; then
    virt-clone --original=k8_vm_template --name=master0 --file=$(pwd)/disks/master0.img;
    virt-clone --original=k8_vm_template --name=master1 --file=$(pwd)/disks/master1.img;
    virt-clone --original=k8_vm_template --name=master2 --file=$(pwd)/disks/master2.img;

    virt-clone --original=k8_vm_template --name=worker0 --file=$(pwd)/disks/worker0.img;
    virt-clone --original=k8_vm_template --name=worker1 --file=$(pwd)/disks/worker1.img;
    virt-clone --original=k8_vm_template --name=worker2 --file=$(pwd)/disks/worker2.img;

    virt-clone --original=k8_vm_template --name=lbl0 --file=$(pwd)/disks/lbl0.img;
fi

#http://libguestfs.org/virt-builder.1.html#ssh-keys
#virt-sysprep --hostname=master0 --ssh-inject=debian --domain=master0