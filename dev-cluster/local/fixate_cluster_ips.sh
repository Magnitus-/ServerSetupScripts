#!/usr/bin/env bash

source ./vars.sh;
source utils.sh;

for VM in $VMS; do
    VM_IP=$(get_domain_ip $VM)
    VM_MAC=$(get_domain_mac $VM)

    virsh net-update $NETWORK_NAME add ip-dhcp-host \
          "<host mac=\"$VM_MAC\" name=\"$VM\" ip=\"$VM_IP\" />" \
          --live --config

done