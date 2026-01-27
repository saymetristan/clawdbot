#!/bin/sh
set -e

# Fix permissions on /data if it exists (Railway volume)
if [ -d "/data" ]; then
  mkdir -p /data/.clawdbot /data/workspace /data/agents/main/agent 2>/dev/null || true
  # Copy config to /data if not exists (so it's writable)
  if [ -f "/app/clawdbot.json" ] && [ ! -f "/data/clawdbot.json" ]; then
    cp /app/clawdbot.json /data/clawdbot.json 2>/dev/null || true
  fi
  chown -R node:node /data 2>/dev/null || true
fi

# Use config from /data if exists
if [ -f "/data/clawdbot.json" ]; then
  export CLAWDBOT_CONFIG_PATH=/data/clawdbot.json
fi

# Create auth-profiles.json from environment variable if set
if [ -n "$CLAWDBOT_AUTH_PROFILES" ]; then
  AUTH_DIR="/data/agents/main/agent"
  mkdir -p "$AUTH_DIR" 2>/dev/null || true
  echo "$CLAWDBOT_AUTH_PROFILES" > "$AUTH_DIR/auth-profiles.json"
  chown -R node:node "$AUTH_DIR" 2>/dev/null || true
  export CLAWDBOT_STATE_DIR=/data
fi

# Switch to node user and run the command
exec gosu node "$@"
