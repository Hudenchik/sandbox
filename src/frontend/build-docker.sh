#!/usr/bin/env bash
set -e

IMAGE_NAME="sandbox-frontend"
TAG="latest"

echo "=== Сборка Docker-образа для фронтенда ==="
docker build -t "${IMAGE_NAME}:${TAG}" -f src/frontend/Dockerfile .

echo "=== Образ ${IMAGE_NAME}:${TAG} успешно собран! ==="
