#!/usr/bin/env bash

docker build -t magnitus/server-setup-scripts .;

if [ ! -d "$(pwd)/keys" ]; then
    echo "keys directory is missing. Please, create it and copy your hosts ssh key(s) in it.";
    exit 1;
fi

docker run --network host -it --rm -v $(pwd)/inventory:/opt/inventory -v $(pwd)/keys:/opt/keys magnitus/server-setup-scripts /bin/bash;