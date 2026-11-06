

# --- Стадия сборки ---
FROM --platform=linux/amd64 golang:1.17-bullseye AS builder
WORKDIR /src

# Копируем зависимости для кэширования слоев
COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download

# Копируем исходный код бэкенда
COPY src/backend/ ./

# Собираем бинарник под linux/amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /out/sandbox-backend ./cmd/api/

# --- Финальная стадия (Runtime) ---
# Используем тот же образ, что и для сборки (golang:1.17-bullseye)
FROM --platform=linux/amd64 golang:1.17-bullseye AS runtime
WORKDIR /app

# Копируем скомпилированный бинарник из стадии builder
COPY --from=builder /out/sandbox-backend /app/sandbox-backend

RUN useradd -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Порт, на котором работает приложение (при необходимости измените)
EXPOSE 8081

# Команда для запуска приложения
CMD ["/app/sandbox-backend"]
