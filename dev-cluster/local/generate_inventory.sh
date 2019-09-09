#!/usr/bin/env bash

source utils.sh;

function write_vm {
    #TODO: Remove arp dependency, use 'virsh domifaddr <domain>' instead...
    VM_IP=$(get_domain_ip $1)
    echo "$VM_IP cluster_hostname=$1" >> $(pwd)/inventory
} 

if [ -f $(pwd)/inventory ]; then
    rm -f $(pwd)/inventory;
fi

touch $(pwd)/inventory;

echo "[all:vars]" >> $(pwd)/inventory;
echo "ansible_connection=ssh" >> $(pwd)/inventory;
echo "ansible_ssh_user=admin" >> $(pwd)/inventory;

echo "" >> $(pwd)/inventory;
echo "[stores]" >> $(pwd)/inventory;

for VM in $(echo "master0 master1 master2"); do
    write_vm $VM
done

echo "" >> $(pwd)/inventory;
echo "[masters]" >> $(pwd)/inventory;

for VM in $(echo "master0 master1 master2"); do
    write_vm $VM
done

echo "" >> $(pwd)/inventory;
echo "[workers]" >> $(pwd)/inventory;

for VM in $(echo "worker0 worker1 worker2"); do
    write_vm $VM
done

echo "" >> $(pwd)/inventory;
echo "[load_balancers]" >> $(pwd)/inventory;

for VM in $(echo "lbl0"); do
    write_vm $VM
done