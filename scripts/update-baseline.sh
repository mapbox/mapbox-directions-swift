#!/usr/bin/env bash

set -e
set -o pipefail
set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BASELINE_DIR="${SCRIPT_DIR}/../swift-package-baseline"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <new_baseline>"
    exit 1
fi

echo "$1" > "${BASELINE_DIR}/baseline.txt"
echo "" > "${BASELINE_DIR}/breakage-allowlist-path.txt"
