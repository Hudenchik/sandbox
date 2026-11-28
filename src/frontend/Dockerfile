# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM node:22-alpine AS base
WORKDIR /app

# 1. Зависимости (редко меняются, установка строго по хэшам из package-lock.json)
COPY src/frontend/package.json src/frontend/package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# 2. Исходный код (часто меняется)
COPY src/frontend/ ./

# --- Стадия тестов и линтеров (CI) ---
FROM base AS test
ENV CI=true
RUN npm run lint --if-present && npm test --if-present

# --- Стадия сборки продакшен-бандла ---
FROM base AS builder
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm run build

# --- Финальный образ (PROD) ---
FROM nginx:1.27-alpine AS runtime
WORKDIR /app

# Один слой: non-root пользователь (UID 10001) и права на директории Nginx
RUN addgroup -g 10001 -S appgroup \
    && adduser -u 10001 -S appuser -G appgroup \
    && sed -i '/^user /d' /etc/nginx/nginx.conf \
    && sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,g; s,/run/nginx.pid,/tmp/nginx.pid,g' /etc/nginx/nginx.conf \
    && chown -R appuser:appgroup /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

# Запускаем http-server для папки dist
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 8888;
    root /app/dist;
    index index.html;

    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;

    location / {
        if (\$request_method = OPTIONS) {
            return 204;
        }
        try_files \$uri \$uri/ @backend;
    }

    location @backend {
        proxy_pass http://my-backend:8081;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

COPY --from=builder --chown=appuser:appgroup /app/dist /app/dist

USER 10001
EXPOSE 8888


