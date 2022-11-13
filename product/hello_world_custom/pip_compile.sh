#!/bin/bash

pip install --upgrade pip

pip install pip-tools

pip-compile --no-build-isolation --generate-hashes --allow-unsafe --output-file="requirements_lock.txt"
