#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

set -a
source .env
set +a

HOST="${1:-$VM_HOST}"
DIR="${REMOTE_DIR:-sandbox}"

REGISTRY="${NEXUS_REPO_URL#http://}"

ssh "$HOST" "mkdir -p '$DIR'"
scp docker-compose.yml .env "$HOST:$DIR/"
ssh "$HOST" "cd '$DIR' && \
  echo '$NEXUS_REPO_PASS' | docker login '$REGISTRY' -u '$NEXUS_REPO_USER' --password-stdin && \
  docker compose pull && docker compose up -d"
