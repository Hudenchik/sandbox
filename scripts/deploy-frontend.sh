#!/usr/bin/env bash
set -euo pipefail

# Подгружаем конфигурацию Nexus
source ./nexus.env

VERSION="${1:-${VERSION}}"
SYSTEMD_SERVICE_NAME="sandbox-frontend.service"
SERVICE_USER="sandbox-frontend"
SERVICE_GROUP="sandbox-frontend"
TARGET_DIR="/opt/sandbox/frontend/site"
FRONTEND_ARCHIVE="sandbox-frontend-${VERSION}.tar.gz"

echo "==> Деплой ${SYSTEMD_SERVICE_NAME} (версия ${VERSION})"

# Создаем сервисного пользователя и группу, если их нет
if ! getent group "${SERVICE_GROUP}" >/dev/null; then
    sudo groupadd --system "${SERVICE_GROUP}"
fi
if ! id -u "${SERVICE_USER}" >/dev/null 2>&1; then
    sudo useradd --system --no-create-home --gid "${SERVICE_GROUP}" --shell /usr/sbin/nologin "${SERVICE_USER}"
fi

# Создаем директории для сервиса, если их нет
sudo mkdir -p "${TARGET_DIR}"

# Скачиваем свежую версию сервиса
curl -f -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  -o "/tmp/${FRONTEND_ARCHIVE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/${FRONTEND_ARCHIVE}"

# Переносим свежую версию сервиса в целевую директорию
# В архиве статика лежит в папке dist/, распакуем во временную папку и перенесем в /opt/sandbox/frontend/site
rm -rf /tmp/frontend_extract && mkdir -p /tmp/frontend_extract
tar -xzf "/tmp/${FRONTEND_ARCHIVE}" -C /tmp/frontend_extract
sudo rm -rf "${TARGET_DIR:?}"/*
sudo cp -r /tmp/frontend_extract/dist/. "${TARGET_DIR}/"

# Выдаем права пользователю и группе фронтенда
sudo chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "/opt/sandbox/frontend"
sudo chmod -R 755 "/opt/sandbox/frontend"
rm -rf "/tmp/${FRONTEND_ARCHIVE}" /tmp/frontend_extract

# Переносим свежую версию конфигурации в целевую директорию systemd
sudo cp "./${SYSTEMD_SERVICE_NAME}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
sudo chmod 644 "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"

# Запускаем сервис
# 1. Перезагрузите конфигурацию systemd, чтобы он увидел новый файл
sudo systemctl daemon-reload

# 2. Запустите сервис прямо сейчас
sudo systemctl restart "${SYSTEMD_SERVICE_NAME}"

# 3. Включите автозапуск при загрузке системы
sudo systemctl enable "${SYSTEMD_SERVICE_NAME}"

echo "==> Сервис ${SYSTEMD_SERVICE_NAME} успешно запущен!"
