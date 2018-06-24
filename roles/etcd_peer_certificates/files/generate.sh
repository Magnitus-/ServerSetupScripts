#!/usr/bin/env bash

PEER_NAME=$(hostname)

if [ ! -f /etc/kubernetes/pki/etcd/peer.pem ]; then
    if [ $ARCHITECTURE = "amd64" ]; then
        IMAGE=magnitus/cfssl:latest
    elif [ $ARCHITECTURE = "arm64" ]; then
        IMAGE=magnitus/cfssl:arm64-latest
    else
        echo "unsupported architecture";
        exit 1;
    fi

    cd /etc/kubernetes/pki/etcd;

    docker run --rm -v $(pwd):/opt $IMAGE cfssl print-defaults csr > config.json;
    sed -i '0,/CN/{s/example\.net/'"$PEER_NAME"'/}' config.json;
    sed -i 's/www\.example\.net/'"$PEER_IP"'/' config.json;
    sed -i 's/example\.net/'"$PEER_NAME"'/' config.json;

    docker run --rm -v $(pwd):/opt $IMAGE cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server config.json \
    | docker run --rm -i -v $(pwd):/opt $IMAGE cfssljson -bare server;
    docker run --rm -v $(pwd):/opt $IMAGE cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer config.json \
    | docker run --rm -i -v $(pwd):/opt $IMAGE cfssljson -bare peer;
fi