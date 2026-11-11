#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

./src/backend/build-docker.sh
./src/frontend/build-docker.sh
