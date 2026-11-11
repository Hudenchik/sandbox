

# --- Стадия сборки ---
FROM node:16-bullseye AS builder
WORKDIR /app

# Установка зависимостей
COPY src/frontend/package.json src/frontend/package-lock.json ./
RUN npm ci

# Копируем исходный код и собираем проект
COPY src/frontend/ ./
RUN npm run build          # Результат сборки: /app/dist

# --- Финальная стадия (Runtime) ---
FROM node:16-bullseye AS runtime
WORKDIR /app

# Устанавливаем http-server глобально для раздачи статики
RUN npm install -g http-server

# Копируем собранный продакшн-бандл из стадии builder
COPY --from=builder --chown=node:node /app/dist /app/dist

USER node

# Порт, который слушает http-server по умолчанию
EXPOSE 8888

# Запускаем http-server для папки dist
CMD ["http-server", "dist", "-p", "8888", "--cors", "--proxy", "http://my-backend:8081"]
