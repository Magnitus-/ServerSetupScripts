#!/usr/bin/env bash

source ./vars.sh;

HOST_NETWORK=$(virsh net-list --all | grep $NETWORK_NAME)

if [ -z "$HOST_NETWORK" ]; then
    virsh net-define --file network-host.xml;
    virsh net-autostart $NETWORK_NAME;
    virsh net-start $NETWORK_NAME;
fi