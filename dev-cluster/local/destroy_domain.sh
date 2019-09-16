#!/usr/bin/env bash
source utils.sh;

VM_NAME=${VM_NAME:-"placeholder"}
DISK_NAME="${VM_NAME}.qcow2"

VM_RUNNING=$(virsh list --name --all | grep $VM_NAME)
if [ ! -z "$VM_RUNNING" ]; then
    VM_IP=$(get_domain_ip $VM_NAME)
    VM_MAC=$(get_domain_mac $VM_NAME)

    if [ ! -z "$VM_IP" ]; then
        virsh net-update $NETWORK_NAME delete ip-dhcp-host \
                "<host mac=\"$VM_MAC\" name=\"$VM\" ip=\"$VM_IP\" />" \
                --live --config || true
    fi

    echo "Destroying previous instance of $VM_NAME...";
    virsh shutdown $VM_NAME 2>/dev/null || true;
    virsh destroy $VM_NAME 2>/dev/null || true;
    virsh undefine $VM_NAME 2>/dev/null || true;
    rm -f ./disks/$DISK_NAME;
fi