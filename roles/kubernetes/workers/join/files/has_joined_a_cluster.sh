#!/usr/bin/env bash

KUBE_PROXY_CONTAINER=$(docker ps | grep k8s_kube-proxy)

if [ -z "$KUBE_PROXY_CONTAINER" ]; then
    echo "no";
else
    echo "yes";
fi