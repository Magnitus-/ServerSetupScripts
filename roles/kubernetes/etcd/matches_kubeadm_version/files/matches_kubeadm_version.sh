#!/usr/bin/env bash

ETCD_IMAGE=$(docker inspect k8_master_etcd -f "{{ .Config.Image }}")
KUBEADM_ETCD_IMAGE=$(kubeadm config images list | grep etcd)

if [ "$ETCD_IMAGE" = "$KUBEADM_ETCD_IMAGE" ]; then
    echo "yes";
else
    echo "no";
fi