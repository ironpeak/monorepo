#!/bin/bash

set -euo pipefail

source pythonpath.sh

set +e
shift
set -e

python "{MAIN}" "$@"

exit 0
