#!/usr/bin/env bash

source utils.sh;

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    VM_IP=$(get_domain_ip $VM)
    VM_MAC=$(get_domain_mac $VM)

    virsh net-update k8-host add ip-dhcp-host \
          "<host mac=\"$VM_MAC\" name=\"$VM\" ip=\"$VM_IP\" />" \
          --live --config

done