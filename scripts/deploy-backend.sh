#!/usr/bin/env bash
set -euo pipefail

# Подгружаем конфигурацию Nexus
source ./nexus.env

VERSION="${1:-${VERSION}}"
SYSTEMD_SERVICE_NAME="sandbox-backend.service"
SERVICE_USER="sandbox-backend"
SERVICE_GROUP="sandbox-backend"
TARGET_DIR="/opt/sandbox/backend"
BACKEND_ARCHIVE="sandbox-backend-${VERSION}.tar.gz"

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
  -o "/tmp/${BACKEND_ARCHIVE}" \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/${BACKEND_ARCHIVE}"

# Переносим свежую версию сервиса в целевую директорию
sudo tar -xzf "/tmp/${BACKEND_ARCHIVE}" -C "${TARGET_DIR}"
# В архиве бинарник называется sandbox-backend, а в .service указан ExecStart=/opt/sandbox/backend/app
sudo mv -f "${TARGET_DIR}/sandbox-backend" "${TARGET_DIR}/app"
sudo chmod 755 "${TARGET_DIR}/app"
sudo chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "${TARGET_DIR}"
rm -f "/tmp/${BACKEND_ARCHIVE}"

# Переносим свежую версию конфигурации в целевую директорию systemd
sudo cp "./${SYSTEMD_SERVICE_NAME}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
sudo chmod 644 "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"

# Запускаем сервис
# 1. Перезагрузите конфигурацию systemd, чтобы он увидел новый файл
sudo systemctl daemon-reload

# 2. Запустите сервис прямо сейчас (restart перезапустит, если уже был запущен)
sudo systemctl restart "${SYSTEMD_SERVICE_NAME}"

# 3. Включите автозапуск при загрузке системы
sudo systemctl enable "${SYSTEMD_SERVICE_NAME}"

echo "==> Сервис ${SYSTEMD_SERVICE_NAME} успешно запущен!"
