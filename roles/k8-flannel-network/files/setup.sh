#!/usr/bin/env bash

FLANNEL_DS=$(kubectl get ds -n kube-system kube-flannel-ds | grep NotFound)
if [ -z "$FLANNEL_DS" ]; then
    #https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
    sysctl net.bridge.bridge-nf-call-iptables=1;
    
    curl https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml --output ~/kube-flannel.yml;
    sed -i "s|amd64|$ARCHITECTURE|g" ~/kube-flannel.yml;
    sed -i "s|10.244.0.0/16|$POD_NETWORK_CIDR|g" ~/kube-flannel.yml;

    kubectl apply -f ~/kube-flannel.yml && rm -f ~/kube-flannel.yml;
fi