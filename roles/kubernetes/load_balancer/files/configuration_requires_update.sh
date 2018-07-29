#!/usr/bin/env bash

UPDATED_CONFIGURATION=no

for ELEMENT in $INVENTORY
do
    if [ -f /opt/haproxy/haproxy.cfg ]; then
        if [ -z "$(cat /opt/haproxy/haproxy.cfg  | grep server | grep $ELEMENT)" ]; then
            UPDATED_CONFIGURATION=yes
        fi
    fi
done

echo $UPDATED_CONFIGURATION;