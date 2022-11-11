#!/bin/bash

pip install pip-tools

pip-compile --generate-hashes --output-file=requirements_lock.txt
