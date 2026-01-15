FROM golang:1.21-alpine AS builder
WORKDIR /app
#https://github.com/qaqwx/RedisShake/tree/v4.5.0
COPY . .
#新增国内镜像加速
ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download
RUN go build -o redis-shake ./cmd/redis-shake

FROM alpine:3.23.2
WORKDIR /app
COPY --from=builder /app/redis-shake .
COPY *.toml .
COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]