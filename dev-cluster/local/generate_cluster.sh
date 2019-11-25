#!/usr/bin/env bash

source ./vars.sh;

WORKER_RAM=${WORKER_RAM:-4096}
WORKER_DISK_SIZE=${WORKER_DISK_SIZE:-10G}
MASTER_RAM=${MASTER_RAM:-2048}
MASTER_DISK_SIZE=${MASTER_DISK_SIZE:-8G}
LBL_RAM=${LBL_RAM:-2048}
LBL_DISK_SIZE=${LBL_DISK_SIZE:-4G}

for VM in $VMS; do
    if [[ "$VM" =~ "master" ]]; then
        RAM=$MASTER_RAM;
        DISK_SIZE=$MASTER_DISK_SIZE;
    elif [[ "$VM" =~ "worker" ]]; then
        RAM=$WORKER_RAM;
        DISK_SIZE=$WORKER_DISK_SIZE;
    else
        RAM=$LBL_RAM;
        DISK_SIZE=$LBL_DISK_SIZE;
    fi
    DISK_SIZE=$DISK_SIZE RAM=$RAM VM_NAME=$VM ./generate_domain.sh;
done

./generate_inventory.sh;
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook set_hosts.yml -i inventory --key-file "./id_rsa";
./shutdown_cluster.sh;
./start_cluster.sh;
./fixate_cluster_ips.sh;