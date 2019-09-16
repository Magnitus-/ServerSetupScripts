export NETWORK_NAME=k8-host;
export CPU_ARCHITECTURE=${CPU_ARCHITECTURE:-"adm64"}
export OS_VARIANT=ubuntu18.04

if [ "$CPU_ARCHITECTURE" = "adm64"  ]; then
    export VM_IMAGE_LOCATION=https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-amd64.img
    export VM_CPU=host-passthrough,cache.mode=passthrough
    export VM_VIRT_TYPE=kvm
    export VM_ARCHITECTURE=x86_64
    export DOWNLOADED_IMAGE_NAME="downloaded_image_amd64.img"
else
    export VM_IMAGE_LOCATION=https://cloud-images.ubuntu.com/daily/server/bionic/current/bionic-server-cloudimg-arm64.img
    export VM_CPU=cortex-a57
    export VM_VIRT_TYPE=qemu
    export VM_ARCHITECTURE=aarch64
    export DOWNLOADED_IMAGE_NAME="downloaded_image_arm64.img"
fi