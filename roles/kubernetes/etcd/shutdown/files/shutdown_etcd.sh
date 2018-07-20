#!/usr/bin/env bash

ETCD_CONTAINER=$(docker ps -a | grep k8_master_etcd)

if [ ! -z "$ETCD_CONTAINER" ]; then
    docker stop k8_master_etcd;
    docker rm -f k8_master_etcd;
fi