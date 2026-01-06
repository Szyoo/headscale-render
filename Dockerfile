FROM ghcr.io/juanfont/headscale:latest

COPY headscale/config.yaml /etc/headscale/config.yaml
COPY headscale/acl.hujson /etc/headscale/acl.hujson
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

ENTRYPOINT ["/start.sh"]
