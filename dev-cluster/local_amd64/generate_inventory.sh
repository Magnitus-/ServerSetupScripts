#!/usr/bin/env bash

function write_vm {
    MAC_ADDRESS=$(virsh domiflist $1 | head -n3 | tail -n1 | tr -s ' ' | cut -d ' ' -f5)
    VM_IP=$(arp -e | grep $MAC_ADDRESS | cut -d ' ' -f1)

    while [ ! -z "$K8_VM_TEMPLATE_RUNNING" ]; do
        sleep 2;
        K8_VM_TEMPLATE_RUNNING=$(virsh list --name | grep k8_vm_template);
    done

    echo "$VM_IP cluster_hostname=$1" >> $(pwd)/inventory
} 

if [ -f $(pwd)/inventory ]; then
    rm -f $(pwd)/inventory;
fi

touch $(pwd)/inventory;

echo "[all:vars]" >> $(pwd)/inventory;
echo "ansible_connection=ssh" >> $(pwd)/inventory;
echo "ansible_ssh_user=debian" >> $(pwd)/inventory;
echo "ansible_ssh_pass=i_am_a_strong_password_i_think" >> $(pwd)/inventory;

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