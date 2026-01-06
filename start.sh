#!/usr/bin/env sh
set -eu

CONFIG_PATH="/etc/headscale/config.yaml"
APIKEY_PATH="/var/lib/headscale/api-key.txt"

headscale serve --config "$CONFIG_PATH" &
HS_PID="$!"

if [ ! -f "$APIKEY_PATH" ]; then
  i=0
  while [ "$i" -lt 60 ]; do
    JSON="$(headscale apikeys create --config "$CONFIG_PATH" --output json --force 2>/dev/null || true)"
    APIKEY="$(printf "%s" "$JSON" | sed -n 's/.*\"apiKey\":\"\\([^\"]*\\)\".*/\\1/p')"
    if [ -z "$APIKEY" ]; then
      APIKEY="$(printf "%s" "$JSON" | sed -n 's/.*\"apikey\":\"\\([^\"]*\\)\".*/\\1/p')"
    fi
    if [ -n "$APIKEY" ]; then
      echo "HEADSCALE_API_KEY=${APIKEY}"
      printf "%s" "$APIKEY" > "$APIKEY_PATH"
      break
    fi
    i=$((i + 1))
    sleep 1
  done
else
  APIKEY="$(cat "$APIKEY_PATH")"
  if [ -n "$APIKEY" ]; then
    echo "HEADSCALE_API_KEY=${APIKEY}"
  fi
fi

wait "$HS_PID"
