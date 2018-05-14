#!/usr/bin/env bash

if [ ! -x "$(command -v cfssl)" ]; then
    if [ $ARCHITECTURE = "amd64" ]; then
        CFSSL_PATH=cfssl_linux-amd64
        CFSSL_JSON_PATH=cfssljson_linux-amd64
    elif [ $ARCHITECTURE = "arm64" ]; then
        CFSSL_PATH=cfssl_linux-arm
        CFSSL_JSON_PATH=cfssljson_linux-arm
    else
        echo "unsupported architecture";
        exit 1;
    fi

    curl -o /usr/local/bin/cfssl https://pkg.cfssl.org/R1.2/$CFSSL_PATH
    curl -o /usr/local/bin/cfssljson https://pkg.cfssl.org/R1.2/$CFSSL_JSON_PATH
    chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson;
fi