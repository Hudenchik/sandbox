# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS base
WORKDIR /src

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=dev

ENV CGO_ENABLED=0 \
    GOFLAGS="-mod=readonly"

# 1. Зависимости (редко меняются)
COPY src/backend/go.mod src/backend/go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download && go mod verify

# 2. Исходный код (часто меняется)
COPY src/backend/ ./

# --- Стадия тестов (CI) ---
FROM base AS test
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go test -race ./...

# --- Стадия сборки бинарника ---
FROM base AS builder
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w -X main.version=${VERSION}" \
    -o /out/sandbox-backend ./cmd/api/

# --- Финальный образ (PROD) ---
FROM alpine:3.21 AS runtime
WORKDIR /app

# Один слой: сертификаты, non-root пользователь и папка для логов
RUN apk add --no-cache ca-certificates \
    && addgroup -g 10001 -S appgroup \
    && adduser -u 10001 -S appuser -G appgroup \
    && mkdir -p /app/logs \
    && chown -R appuser:appgroup /app

COPY --from=builder --chown=appuser:appgroup /out/sandbox-backend /app/sandbox-backend

ENV LOG_FILE=/app/logs/backend.log
USER 10001
EXPOSE 8081

CMD ["/app/sandbox-backend"]