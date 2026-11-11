#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

set -a
source .env
set +a

REGISTRY="${NEXUS_REPO_URL#http://}"
IMAGE="${REGISTRY}/${NEXUS_REPO_BACKEND_DOCKER}/sandbox-backend:latest"


echo "$NEXUS_REPO_PASS" | docker login "$REGISTRY" -u "$NEXUS_REPO_USER" --password-stdin
docker build --platform linux/amd64 -t "$IMAGE" -f src/backend/Dockerfile .
docker push "$IMAGE"