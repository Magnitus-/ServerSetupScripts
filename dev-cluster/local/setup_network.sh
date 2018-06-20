#!/usr/bin/env bash

HOST_NETWORK=$(virsh net-list --all | grep k8-host)

if [ -z "$HOST_NETWORK" ]; then
    virsh net-define --file network-host.xml;
    virsh net-autostart k8-host;
    virsh net-start k8-host;
fi