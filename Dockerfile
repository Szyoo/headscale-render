FROM ghcr.io/juanfont/headscale:latest

COPY headscale/config.yaml /etc/headscale/config.yaml
COPY headscale/acl.hujson /etc/headscale/acl.hujson

EXPOSE 8080

CMD ["headscale", "serve", "--config", "/etc/headscale/config.yaml"]
