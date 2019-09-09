#!/usr/bin/env bash

DISK_SIZE=${DISK_SIZE:-4}
VIRTUAL_CPUS=${VIRTUAL_CPUS:-4}
VM_TEMPLATE=${VM_TEMPLATE:-"k8_vm_template"}

K8_VM_TEMPLATE=$(virsh list --name --all | grep $VM_TEMPLATE)

OS_VARIANT=ubuntu18.04
DISK_NAME="$VM_TEMPLATE.qcow2"
if [ "$VM_TEMPLATE" = "k8_vm_template"  ]; then
    VM_IMAGE_LOCATION=https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-amd64.img
    VM_CPU=host-passthrough,cache.mode=passthrough
    VM_VIRT_TYPE=kvm
    VM_ARCHITECTURE=x86_64
    DOWNLOADED_IMAGE_NAME="downloaded_image_amd64.img"
else
    VM_IMAGE_LOCATION=https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-arm64.img
    VM_CPU=cortex-a57
    VM_VIRT_TYPE=qemu
    VM_ARCHITECTURE=aarch64
    DOWNLOADED_IMAGE_NAME="downloaded_image_arm64.img"
fi

if [ ! -z "$K8_VM_TEMPLATE" ]; then
    echo "Destroying previous instance...";
    virsh destroy $VM_TEMPLATE 2>/dev/null || true;
    virsh undefine $VM_TEMPLATE 2>/dev/null || true;
fi

mkdir -p $(pwd)/disks;
if [ ! -f "./disks/$DOWNLOADED_IMAGE_NAME" ]; then
    echo "Downloading source image...";
    wget $VM_IMAGE_LOCATION -O ./disks/$DOWNLOADED_IMAGE_NAME;
fi

if [ -f "./disks/$DISK_NAME" ]; then
    echo "Deleting previous instance disk...";
    rm -f ./disks/$DISK_NAME;
fi

(
    cd disks;
    qemu-img create -b $DOWNLOADED_IMAGE_NAME -f qcow2 $DISK_NAME;
    qemu-img resize $DISK_NAME ${DISK_SIZE}G;
);

rm -f id_rsa id_rsa.pub;
ssh-keygen -t rsa -f id_rsa -q -N "";

rm -f user-data;
sed -e "s/{{ssh_pub_key}}/$(sed 's:/:\\/:g' id_rsa.pub)/" user-data.j2 > user-data;

rm -f seed.iso;
cloud-localds seed.iso user-data meta-data;

virt-install \
--name=$VM_TEMPLATE \
--ram=1024 \
--vcpus=$VIRTUAL_CPUS \
--cpu $VM_CPU \
--disk path=./disks/$DISK_NAME,format=qcow2,bus=virtio \
--disk path=./seed.iso,device=cdrom \
--os-type linux \
--os-variant $OS_VARIANT \
--arch $VM_ARCHITECTURE \
--virt-type=$VM_VIRT_TYPE \
--controller usb,model=none \
--graphics none \
--noautoconsole \
--network network=k8-host;

IP_ADDRESS=$(virsh domifaddr $VM_TEMPLATE | grep ipv4)
while [ -z "$IP_ADDRESS" ]; do
    echo "Waiting for template to boot...";
    sleep 2;
    IP_ADDRESS=$(virsh domifaddr $VM_TEMPLATE | grep ipv4)
done
virsh shutdown $VM_TEMPLATE;