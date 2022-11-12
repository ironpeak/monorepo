#!/bin/bash

platform="$1"

pip install pip-tools

pip-compile --build-isolation --generate-hashes --output-file="requirements_${platform}_lock.txt"
