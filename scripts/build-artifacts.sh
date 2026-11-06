#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-${VERSION:-$(date -u +%Y%m%dT%H%M%SZ)}}"
echo "==> Сборка версии: ${VERSION}"

rm -rf output/backend output/frontend
mkdir -p output/backend output/frontend

DOCKER_BUILDKIT=1 docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  -f build/backend.Dockerfile \
  --target artifact \
  --output "type=local,dest=output/backend" \
  .

DOCKER_BUILDKIT=1 docker buildx build \
  --provenance=false \
  -f build/frontend.Dockerfile \
  --target artifact \
  --output "type=local,dest=output/frontend" \
  .

chmod 755 output/backend/sandbox-backend

tar -czf "output/sandbox-backend-${VERSION}.tar.gz" -C output/backend sandbox-backend
tar -czf "output/sandbox-frontend-${VERSION}.tar.gz" -C output/frontend dist default.conf

printf '%s' "${VERSION}" > output/.last-version
echo "==> Готово: output/sandbox-backend-${VERSION}.tar.gz и output/sandbox-frontend-${VERSION}.tar.gz"
