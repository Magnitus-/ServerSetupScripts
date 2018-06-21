#!/usr/bin/env bash

VM_TEMPLATE=${VM_TEMPLATE:-"k8_vm_template"}

source utils.sh;

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    VM_IP=$(get_domain_ip $VM)
    VM_MAC=$(get_domain_mac $VM)

    virsh net-update k8-host delete ip-dhcp-host \
          "<host mac=\"$VM_MAC\" name=\"$VM\" ip=\"$VM_IP\" />" \
          --live --config
done

./shutdown_cluster.sh;

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    if [ "$VM_TEMPLATE" = "k8_vm_template"  ]; then
       virsh undefine $VM;
    else
       virsh undefine --nvram $VM;
    fi
done

for FILENAME in $(pwd)/disks/*; do
    if [[ "$(basename $FILENAME)" =~ ^(master|worker|lbl).*$ ]]; then
        rm -f $FILENAME;
    fi
done