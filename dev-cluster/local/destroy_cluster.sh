#!/usr/bin/env bash

source ./vars.sh;

for VM in $(echo "master0 master1 master2 worker0 worker1 worker2 lbl0"); do
    VM_NAME=$VM ./destroy_domain.sh;
done