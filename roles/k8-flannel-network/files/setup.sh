#!/usr/bin/env bash

#https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
sysctl net.bridge.bridge-nf-call-iptables=1;

curl https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml --output $HOME/kube-flannel.yml;
sed -i "s|amd64|$ARCHITECTURE|g" $HOME/kube-flannel.yml;
sed -i "s|10.244.0.0/16|$POD_NETWORK_CIDR|g" $HOME/kube-flannel.yml;

su $KUBERNETES_ADMIN -c 'kubectl apply -f $HOME/kube-flannel.yml && rm -f $HOME/kube-flannel.yml';