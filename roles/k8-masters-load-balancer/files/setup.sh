#!/usr/bin/env bash

HAPROXY_CONTAINER=$(docker ps -a | grep k8_masters_load_balancer)

if [ -z "$HAPROXY_CONTAINER" ]; then

    if [ "$ARCHITECTURE" = "amd64" ]; then
        IMAGE="haproxy:1.8"
    else
        IMAGE="arm64v8/haproxy:1.8"
    fi

    docker run -d --restart=always --name=k8_masters_load_balancer --network=host -v /opt/haproxy:/usr/local/etc/haproxy:ro $IMAGE;
fi