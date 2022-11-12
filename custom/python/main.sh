#!/bin/bash

set -euo pipefail

source pythonpath.sh

shift

python "{MAIN}" "$@"

exit 0
