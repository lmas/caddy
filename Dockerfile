
ARG GO_VERSION=1.12
FROM golang:${GO_VERSION}-alpine AS builder

RUN apk add --no-cache ca-certificates git && \
        mkdir -p /build/etc/ssl/certs && \
        cp /etc/ssl/certs/ca-certificates.crt /build/etc/ssl/certs/

WORKDIR /src
COPY . .
RUN go mod download && \
        cd caddy/ && \
        CGO_ENABLED=0 go build -o /build/app

################################################################################

#FROM alpine:3.9 AS final
FROM scratch AS final

COPY --from=builder --chown=2003:2003 /build /

USER 2003:2003
ENV HOME /data
WORKDIR $HOME
VOLUME $HOME
EXPOSE 8080 8081

CMD ["/app", "-agree", "-log=stdout", "-conf=/data/Caddyfile", "-ca=https://acme-staging-v02.api.letsencrypt.org/directory", "-http-port=8080", "-https-port=8081", "-quiet"]

