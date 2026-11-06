# syntax=docker/dockerfile:1

# Стадия сборки: всегда linux/amd64, независимо от того, что хост — Apple Silicon
FROM --platform=linux/amd64 golang:1.17-bullseye AS builder
WORKDIR /src

# сначала зависимости — слой кэшируется
COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download

COPY src/backend/ ./

# то же, что в задании, но с явным GOARCH и сборкой пакета
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /out/sandbox-backend ./cmd/api/

# Финальная стадия только с артефактом — отсюда забираем файл через --output type=local
FROM scratch AS artifact
COPY --from=builder /out/sandbox-backend /sandbox-backend
