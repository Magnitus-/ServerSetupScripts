#!/usr/bin/env bash

source ./vars.sh;

for VM in $VMS; do
    VM_NAME=$VM ./destroy_domain.sh;
done