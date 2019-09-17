#!/usr/bin/env bash
source ./vars.sh;

for VM in $VMS; do
    virsh shutdown $VM;
done

for VM in $VMS; do
    VM_UP=$(virsh list | grep $VM)
    while [ ! -z "$VM_UP" ]; do
        VM_UP=$(virsh list | grep $VM)
    done
done