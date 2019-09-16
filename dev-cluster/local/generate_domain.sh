#!/usr/bin/env bash

DISK_SIZE=${DISK_SIZE:-4G}
VIRTUAL_CPUS=${VIRTUAL_CPUS:-4}
RAM=${RAM:-1024}
VM_NAME=${VM_NAME:-"placeholder"}
DISK_NAME="${VM_NAME}.qcow2"

echo "****VM SETUP****"
echo "Name: $VM_NAME"
echo "Ram: $RAM"
echo "Virtual cores: $VIRTUAL_CPUS"
echo "Cpus: $VM_CPU"
echo "OS Variant: $OS_VARIANT"
echo "Architecture: $VM_ARCHITECTURE"
echo "Hypervisor: $VM_VIRT_TYPE"
echo "Disk: disks/$DISK_NAME"
echo "Disk Size: $DISK_SIZE"


(
    cd disks;
    qemu-img create -b $DOWNLOADED_IMAGE_NAME -f qcow2 $DISK_NAME;
    qemu-img resize $DISK_NAME ${DISK_SIZE};
);

virt-install \
--name=$VM_NAME \
--ram=$RAM \
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
--network network=$NETWORK_NAME;

IP_ADDRESS=$(virsh domifaddr $VM_NAME | grep ipv4)
while [ -z "$IP_ADDRESS" ]; do
    echo "Waiting for $VM_NAME  to boot...";
    sleep 2;
    IP_ADDRESS=$(virsh domifaddr $VM_NAME | grep ipv4)
done
virsh change-media $VM_NAME  hda --eject --config --live;