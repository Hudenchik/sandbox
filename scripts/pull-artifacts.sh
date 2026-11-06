#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

set -a
source scripts/nexus.env
set +a

VERSION="${1:-${VERSION:-$(cat output/.last-version)}}"
echo "==> Скачивание из Nexus версии: ${VERSION}"

mkdir -p output

BACKEND_FILE="sandbox-backend-${VERSION}.tar.gz"
FRONTEND_FILE="sandbox-frontend-${VERSION}.tar.gz"

curl -f -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  -o "output/${BACKEND_FILE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/${BACKEND_FILE}"

curl -f -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  -o "output/${FRONTEND_FILE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/${FRONTEND_FILE}"

echo "==> Артефакты скачаны в output/${BACKEND_FILE} и output/${FRONTEND_FILE}"
