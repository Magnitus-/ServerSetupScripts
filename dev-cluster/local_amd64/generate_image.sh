#!/usr/bin/env bash

DISK_SIZE=${DISK_SIZE:-4}
VIRTUAL_CPUS=${VIRTUAL_CPUS:-4}

K8_VM_TEMPLATE=$(virsh list --name --all | grep k8_vm_template)

if [ -z "$K8_VM_TEMPLATE" ]; then
    mkdir -p $(pwd)/disks;

    virt-install \
    --name=k8_vm_template \
    --ram=1024 \
    --vcpus=$VIRTUAL_CPUS \
    --cpu host-passthrough,cache.mode=passthrough \
    --disk size=$DISK_SIZE,path=$(pwd)/disks/k8_template.img,bus=virtio,cache=none \
    --initrd-inject=preseed.cfg \
    --location http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/ \
    --os-type linux \
    --os-variant debian9 \
    --virt-type=kvm \
    --controller usb,model=none \
    --graphics none \
    --noautoconsole \
    --network network=k8-host \
    --noreboot \
    --extra-args="auto=true console=tty0 console=ttyS0,115200n8 serial"

    K8_VM_TEMPLATE_RUNNING=$(virsh list --name | grep k8_vm_template);
    while [ ! -z "$K8_VM_TEMPLATE_RUNNING" ]; do
        sleep 2;
        K8_VM_TEMPLATE_RUNNING=$(virsh list --name | grep k8_vm_template);
    done
fi
