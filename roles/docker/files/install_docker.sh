#!/usr/bin/env bash

if [ ! -x "$(command -v docker)" ]; then
    apt-get install -y curl;
    curl -fsSL https://get.docker.com/ | sh
fi
