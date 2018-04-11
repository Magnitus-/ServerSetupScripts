#!/usr/bin/env bash

if [ ! -x "$(command -v pip)" ]; then
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | python
fi
