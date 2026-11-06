#!/usr/bin/env bash
set -e

IMAGE_NAME="sandbox-backend"
TAG="latest"

echo "=== Сборка Docker-образа для бэкенда ==="
docker build -t "${IMAGE_NAME}:${TAG}" -f src/backend/Dockerfile .

echo "=== Образ ${IMAGE_NAME}:${TAG} успешно собран! ==="
