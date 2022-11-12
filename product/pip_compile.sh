#!/bin/bash

pip install pip-tools

pip-compile --build-isolation --generate-hashes --output-file=requirements_lock.txt
