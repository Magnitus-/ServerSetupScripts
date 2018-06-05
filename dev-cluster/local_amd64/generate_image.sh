#!/usr/bin/env bash

K8_VM_TEMPLATE=$(virsh list --name --all | grep k8_vm_template)

if [ -z "$K8_VM_TEMPLATE" ]; then
    mkdir -p $(pwd)/disks;

    virt-install \
    --name=k8_vm_template \
    --ram=1024 \
    --vcpus=4 \
    --cpu host-passthrough,cache.mode=passthrough \
    --disk size=4,path=$(pwd)/disks/v8_template.img,bus=virtio,cache=none \
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
