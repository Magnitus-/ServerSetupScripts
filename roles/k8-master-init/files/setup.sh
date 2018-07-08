#!/usr/bin/env bash

if [ ! -f /etc/kubernetes/admin.conf ]; then

    INITIAL_CLUSTER=""
    INDEX=$((0))

    for ELEMENT in $INVENTORY
    do
        INITIAL_CLUSTER="${INITIAL_CLUSTER}
  - https://${ELEMENT}:2379"
        INDEX=$((INDEX+1))
    done

cat >/opt/config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: ${API_URL}
etcd:
  endpoints:${INITIAL_CLUSTER}
  caFile: /etc/kubernetes/pki/etcd/ca.pem
  certFile: /etc/kubernetes/pki/etcd/client.pem
  keyFile: /etc/kubernetes/pki/etcd/client-key.pem
networking:
  podSubnet: ${POD_NETWORK_CIDR}
apiServerCertSANs:
- ${API_URL}
apiServerExtraArgs:
  apiserver-count: "${INDEX}"
EOF

    ln -sf /etc/pki/etcd /etc/kubernetes/pki/etcd;
    kubeadm init --config=/opt/config.yaml;
    rm /opt/config.yaml;

    #For the admin to access kubernetes with the right configurations
    mkdir -p /home/$KUBERNETES_ADMIN/.kube;
    cp /etc/kubernetes/admin.conf /home/$KUBERNETES_ADMIN/.kube/config;
    chown -R $KUBERNETES_ADMIN:$KUBERNETES_ADMIN /home/$KUBERNETES_ADMIN/.kube;

    #For the root to access kubernetes with the right configurations
    mkdir -p /root/.kube;
    cp /etc/kubernetes/admin.conf /root/.kube/config;
    chown -R root:root /root/.kube;
fi