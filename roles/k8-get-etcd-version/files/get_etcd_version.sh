#!/usr/bin/env bash

echo $(docker inspect k8_master_etcd -f '{{.Config.Image}}' | sed -En 's|.*etcd:v([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+).*|\1|p')