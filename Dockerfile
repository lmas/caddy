
ARG GO_VERSION=1.12
FROM golang:${GO_VERSION}-alpine AS builder

RUN apk add --no-cache ca-certificates git && \
        mkdir -p /build/etc/ssl/certs && \
        cp /etc/ssl/certs/ca-certificates.crt /build/etc/ssl/certs/

WORKDIR /src
COPY . .
RUN go mod download && \
        cd caddy/ && \
        CGO_ENABLED=0 go build -o /build/caddy

################################################################################

#FROM alpine:3.9 AS final
FROM scratch AS final

COPY --from=builder /build /

ENV HOME /data
WORKDIR $HOME
VOLUME $HOME
VOLUME /conf
EXPOSE 8080 8081

#CMD ["/app", "-agree", "-log=stdout", "-conf=/conf/Caddyfile", "-ca=https://acme-staging-v02.api.letsencrypt.org/directory", "-http-port=8080", "-https-port=8081", "-quiet"]
CMD ["/caddy", "-agree", "-log=stdout", "-conf=/conf/Caddyfile", "-http-port=8080", "-https-port=8081", "-quiet"]

