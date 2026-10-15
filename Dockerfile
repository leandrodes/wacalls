# ---- Etapa 1: cliente React (served pelo próprio servidor) ----
FROM node:22-alpine AS client
WORKDIR /app/client
COPY client/package.json client/package-lock.json ./
RUN npm ci
COPY client/ ./
RUN npm run build && test -f dist/index.html

# ---- Etapa 2: servidor Go (puro Go, sem CGO) ----
FROM golang:1.26-alpine AS server
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -trimpath -ldflags "-s -w" -o /out/wacalls ./cmd/server

# ---- Etapa 3: runtime ----
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=server /out/wacalls /usr/local/bin/wacalls
COPY --from=client /app/client/dist /app/client/dist

# Tudo persistente (SQLite + WAL) fica em /data
WORKDIR /data
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/wacalls"]
CMD ["-addr", ":8080", "-static", "/app/client/dist", "-db", "wacalls.db"]
