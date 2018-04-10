#!/usr/bin/env bash

if [ ! -x "$(command -v docker)" ]; then
    curl -fsSL https://get.docker.com/ | sh
fi
