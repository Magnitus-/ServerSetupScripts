#!/usr/bin/env bash

HAPROXY_CONTAINER=$(docker ps -a | grep k8_masters_load_balancer)

if [ -z "$HAPROXY_CONTAINER" ]; then
    docker run -d --restart=always --name=k8_masters_load_balancer --network=host -v /opt/haproxy:/usr/local/etc/haproxy:ro haproxy:1.8;
fi