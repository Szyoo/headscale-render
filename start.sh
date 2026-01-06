#!/usr/bin/env sh
set -eu

CONFIG_PATH="/etc/headscale/config.yaml"
APIKEY_PATH="/var/lib/headscale/api-key.txt"

headscale serve --config "$CONFIG_PATH" &
HS_PID="$!"

if [ ! -f "$APIKEY_PATH" ]; then
  i=0
  while [ "$i" -lt 60 ]; do
    echo "HEADSCALE_APIKEY_GENERATE_ATTEMPT=$((i + 1))"
    JSON="$(headscale apikeys create --config "$CONFIG_PATH" --output json-line --force 2>&1 || true)"
    if [ -n "$JSON" ]; then
      echo "HEADSCALE_APIKEY_JSON=${JSON}"
    fi
    APIKEY="$(printf "%s" "$JSON" | sed -n 's/.*\"apiKey\":\"\\([^\"]*\\)\".*/\\1/p')"
    if [ -z "$APIKEY" ]; then
      APIKEY="$(printf "%s" "$JSON" | sed -n 's/.*\"apikey\":\"\\([^\"]*\\)\".*/\\1/p')"
    fi
    if [ -z "$APIKEY" ]; then
      case "$JSON" in
        \{*) ;; # JSON object, already handled
        *) APIKEY="$JSON" ;;
      esac
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
