#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

set -a
source .env
set +a

VERSION="${1:-${VERSION:-$(cat output/.last-version)}}"
echo "==> Загрузка в Nexus версии: ${VERSION}"

BACKEND_FILE="sandbox-backend-${VERSION}.tar.gz"
FRONTEND_FILE="sandbox-frontend-${VERSION}.tar.gz"

curl -f -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  --upload-file "output/${BACKEND_FILE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/${BACKEND_FILE}"

curl -f -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  --upload-file "output/${FRONTEND_FILE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/${FRONTEND_FILE}"

echo "==> Артефакты версии ${VERSION} успешно загружены в Nexus"
