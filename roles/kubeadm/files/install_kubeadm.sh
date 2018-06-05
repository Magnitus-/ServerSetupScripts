#!/usr/bin/env bash

#https://kubernetes.io/docs/setup/independent/install-kubeadm/
if [ ! -x "$(command -v kubeadm)" ]; then
    apt-get update && apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update;
    apt-get install -y kubelet kubeadm kubectl;
    swapoff -a;
fi
