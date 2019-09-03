#!/usr/bin/env bash

DISK_SIZE=${DISK_SIZE:-4}
VIRTUAL_CPUS=${VIRTUAL_CPUS:-4}
VM_TEMPLATE=${VM_TEMPLATE:-"k8_vm_template"}

K8_VM_TEMPLATE=$(virsh list --name --all | grep $VM_TEMPLATE)

if [ "$VM_TEMPLATE" = "k8_vm_template"  ]; then
    VM_IMAGE_LOCATION=http://ftp.us.debian.org/debian/dists/stretch/main/installer-amd64/
    VM_CPU=host-passthrough,cache.mode=passthrough
    VM_VIRT_TYPE=kvm
    VM_ARCHITECTURE=x86_64
else
    VM_IMAGE_LOCATION=http://ftp.us.debian.org/debian/dists/stretch/main/installer-arm64/
    VM_CPU=cortex-a57
    VM_VIRT_TYPE=qemu
    VM_ARCHITECTURE=aarch64
fi


if [ -z "$K8_VM_TEMPLATE" ]; then
    mkdir -p $(pwd)/disks;

    virt-install \
    --name=$VM_TEMPLATE \
    --ram=1024 \
    --vcpus=$VIRTUAL_CPUS \
    --cpu $VM_CPU \
    --disk size=$DISK_SIZE,path=$(pwd)/disks/k8_template.img,bus=virtio,cache=none \
    --initrd-inject=preseed.cfg \
    --location $VM_IMAGE_LOCATION \
    --os-type linux \
    --os-variant debian9 \
    --arch $VM_ARCHITECTURE \
    --virt-type=$VM_VIRT_TYPE \
    --controller usb,model=none \
    --graphics none \
    --noautoconsole \
    --network network=k8-host \
    --noreboot \
    --extra-args="auto=true console=tty0 console=ttyS0,115200n8 serial"

    K8_VM_TEMPLATE_RUNNING=$(virsh list --name | grep $VM_TEMPLATE);
    while [ ! -z "$K8_VM_TEMPLATE_RUNNING" ]; do
        sleep 2;
        K8_VM_TEMPLATE_RUNNING=$(virsh list --name | grep $VM_TEMPLATE);
    done
fi
