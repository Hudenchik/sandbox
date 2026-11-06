# syntax=docker/dockerfile:1

# node 16 обязателен: на node 17+ webpack 4 падает с ERR_OSSL_EVP_UNSUPPORTED
FROM node:16-bullseye AS builder
WORKDIR /app

COPY src/frontend/package.json src/frontend/package-lock.json ./
RUN npm ci

COPY src/frontend/ ./
RUN npm run build          # результат: /app/dist

FROM scratch AS artifact
COPY --from=builder /app/dist /dist
COPY --from=builder /app/default.conf /default.conf
