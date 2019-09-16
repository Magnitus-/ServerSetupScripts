#!/usr/bin/env bash

source ./vars.sh;

HOST_NETWORK=$(virsh net-list --all | grep $NETWORK_NAME)

if [ ! -z "$HOST_NETWORK" ]; then
    virsh net-destroy $NETWORK_NAME;
    virsh net-undefine $NETWORK_NAME;
fi