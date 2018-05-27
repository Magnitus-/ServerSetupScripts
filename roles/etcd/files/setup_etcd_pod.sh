#!/usr/bin/env bash

INITIAL_CLUSTER=""
INDEX=$((0))

for ELEMENT in $INVENTORY
do
    if [ -z "$INITIAL_CLUSTER" ]; then
        INITIAL_CLUSTER="etcd${INDEX}=https://${ELEMENT}:2380"
    else
        INITIAL_CLUSTER="${INITIAL_CLUSTER},etcd${INDEX}=https://${ELEMENT}:2380"
    fi

    if [ "$ELEMENT" == "$PEER_IP" ]; then
        NAME="etcd${INDEX}"
    fi

    INDEX=$((INDEX+1))
done

if [ "$ARCHITECTURE" = "amd64" ]; then
    IMAGE=quay.io/coreos/etcd:v3.1.14
else
    IMAGE=quay.io/coreos/etcd:v3.1.14-arm64
fi

CMD="etcd \
--name=${NAME}
--data-dir=/var/lib/etcd \
--listen-client-urls https://${PEER_IP}:2379 \
--advertise-client-urls https://${PEER_IP}:2379 \
--listen-peer-urls https://${PEER_IP}:2380 \
--initial-advertise-peer-urls https://${PEER_IP}:2380 \
--cert-file=/certs/server.pem \
--key-file=/certs/server-key.pem \
--client-cert-auth \
--trusted-ca-file=/certs/ca.pem \
--peer-cert-file=/certs/peer.pem \
--peer-key-file=/certs/peer-key.pem \
--peer-client-cert-auth \
--peer-trusted-ca-file=/certs/ca.pem \
--initial-cluster ${INITIAL_CLUSTER} \
--initial-cluster-token my-etcd-token \
--initial-cluster-state new"

#TODO: Add health check
docker run -d \
           --name="k8_master_etcd" \
           --restart=always \
           --network=host \
           --entrypoint="" \
           -v /var/lib/etcd:/var/lib/etcd \
           -v /etc/kubernetes/pki/etcd:/certs \
           $IMAGE $CMD;

