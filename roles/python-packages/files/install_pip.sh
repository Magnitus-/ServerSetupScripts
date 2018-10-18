#!/usr/bin/env bash

if [ ! -z "$(which python)" ]
    PYTHON_COMMAND=python
else
    PYTHON_COMMAND=python3
fi

if [ ! -x "$(command -v pip)" ]; then
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | $PYTHON_COMMAND
fi
