FROM ghcr.io/juanfont/headscale:latest AS headscale

FROM alpine:3.20
RUN apk add --no-cache ca-certificates

COPY --from=headscale /headscale /usr/local/bin/headscale
COPY --chmod=0755 start.sh /start.sh
COPY headscale/config.yaml /etc/headscale/config.yaml
COPY headscale/acl.hujson /etc/headscale/acl.hujson

EXPOSE 8080

ENTRYPOINT ["/start.sh"]
