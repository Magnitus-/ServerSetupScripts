#!/usr/bin/env bash

PEER_NAME=$(hostname)

if [ ! -f /etc/kubernetes/pki/etcd/peer.pem ]; then
    cd /etc/kubernetes/pki/etcd;

    cfssl print-defaults csr > config.json;
    sed -i '0,/CN/{s/example\.net/'"$PEER_NAME"'/}' config.json;
    sed -i 's/www\.example\.net/'"$SELF_IP"'/' config.json;
    sed -i 's/example\.net/'"$PEER_NAME"'/' config.json;

    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server config.json | cfssljson -bare server;
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer config.json | cfssljson -bare peer;
fi