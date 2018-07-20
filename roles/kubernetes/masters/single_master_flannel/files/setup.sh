#!/usr/bin/env bash

#https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
kubeadm init --pod-network-cidr $POD_NETWORK_CIDR;
sysctl net.bridge.bridge-nf-call-iptables=1;

curl https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml --output /home/$KUBERNETES_ADMIN/kube-flannel.yml;
sed -i "s|amd64|$ARCHITECTURE|g" /home/$KUBERNETES_ADMIN/kube-flannel.yml;
sed -i "s|10.244.0.0/16|$POD_NETWORK_CIDR|g" /home/$KUBERNETES_ADMIN/kube-flannel.yml;

mkdir -p /home/$KUBERNETES_ADMIN/.kube;
cp /etc/kubernetes/admin.conf /home/$KUBERNETES_ADMIN/.kube/config;
chown -R $KUBERNETES_ADMIN:$KUBERNETES_ADMIN /home/$KUBERNETES_ADMIN;

su $KUBERNETES_ADMIN -c 'kubectl apply -f $HOME/kube-flannel.yml && rm -f $HOME/kube-flannel.yml';
