#!/usr/bin/env sh
set -eu

CONFIG_PATH="/etc/headscale/config.yaml"
APIKEY_PATH="/var/lib/headscale/api-key.txt"

if [ ! -f "$APIKEY_PATH" ]; then
  APIKEY="$(headscale apikeys create --config "$CONFIG_PATH")"
  echo "HEADSCALE_API_KEY=${APIKEY}"
  printf "%s" "$APIKEY" > "$APIKEY_PATH"
fi

exec headscale serve --config "$CONFIG_PATH"
