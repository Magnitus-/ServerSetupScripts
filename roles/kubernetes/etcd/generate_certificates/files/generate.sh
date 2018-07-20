#!/usr/bin/env bash

if [ ! -d /etc/pki/etcd ]; then
    if [ $ARCHITECTURE = "amd64" ]; then
        IMAGE=magnitus/cfssl:latest
    elif [ $ARCHITECTURE = "arm64" ]; then
        IMAGE=magnitus/cfssl:arm64-latest
    else
        echo "unsupported architecture";
        exit 1;
    fi

    mkdir -p /etc/pki/etcd;
    cd /etc/pki/etcd;
    
    #Service certificates generation
    cat >ca-config.json <<EOF
{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}
EOF

   cat >ca-csr.json <<EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    }
}
EOF

    docker run --rm -v $(pwd):/opt $IMAGE cfssl gencert -initca ca-csr.json \
    | docker run --rm -i -v $(pwd):/opt $IMAGE cfssljson -bare ca -

    #Client certificate generation
   cat >client.json <<EOF
{
    "CN": "client",
    "key": {
        "algo": "ecdsa",
        "size": 256
    }
}
EOF

    docker run --rm -v $(pwd):/opt $IMAGE cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client.json \
    | docker run --rm -i -v $(pwd):/opt $IMAGE cfssljson -bare client -
fi