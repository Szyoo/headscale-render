#!/usr/bin/env sh
set -eu

CONFIG_PATH="/etc/headscale/config.yaml"
APIKEY_PATH="/var/lib/headscale/api-key.txt"

headscale serve --config "$CONFIG_PATH" &
HS_PID="$!"

if [ ! -f "$APIKEY_PATH" ]; then
  i=0
  while [ "$i" -lt 30 ]; do
    if APIKEY="$(headscale apikeys create --config "$CONFIG_PATH" --output json 2>/dev/null | sed -n 's/.*\"apikey\":\"\\([^\"]*\\)\".*/\\1/p')"; then
      if [ -n "$APIKEY" ]; then
        echo "HEADSCALE_API_KEY=${APIKEY}"
        printf "%s" "$APIKEY" > "$APIKEY_PATH"
        break
      fi
    fi
    i=$((i + 1))
    sleep 1
  done
fi

wait "$HS_PID"
