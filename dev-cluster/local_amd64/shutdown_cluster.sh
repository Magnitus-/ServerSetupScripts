#!/usr/bin/env bash

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    virsh shutdown $VM;
done

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    VM_UP=$(virsh list | grep $VM)
    while [ ! -z "$VM_UP" ]; do
        VM_UP=$(virsh list | grep $VM)
    done
done