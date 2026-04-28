# syntax=docker/dockerfile:1.7

FROM golang:1.25.1-alpine AS builder

WORKDIR /src/Server/MuchToDo

RUN apk add --no-cache git ca-certificates

COPY Server/MuchToDo/go.mod Server/MuchToDo/go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY Server/MuchToDo/ ./

RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/much-to-do ./cmd/api

FROM alpine:3.21 AS runtime

RUN apk add --no-cache ca-certificates tzdata wget \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /out/much-to-do /usr/local/bin/much-to-do

RUN chown appuser:appgroup /usr/local/bin/much-to-do

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/much-to-do"]
