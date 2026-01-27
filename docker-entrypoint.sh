#!/bin/sh
set -e

# Fix permissions on /data if it exists (Railway volume)
if [ -d "/data" ]; then
  mkdir -p /data/.clawdbot /data/workspace /data/agents/main/agent 2>/dev/null || true
  # Always copy config from image to /data (overwrite if exists)
  if [ -f "/app/clawdbot.json" ]; then
    cp /app/clawdbot.json /data/clawdbot.json 2>/dev/null || true
  fi
  # Create auth-profiles.json from env vars if provided
  if [ -n "$OPENAI_CODEX_ACCESS" ] && [ -n "$OPENAI_CODEX_REFRESH" ]; then
    cat > /data/agents/main/agent/auth-profiles.json << EOF
{
  "version": 1,
  "profiles": {
    "openai-codex:default": {
      "type": "oauth",
      "provider": "openai-codex",
      "access": "$OPENAI_CODEX_ACCESS",
      "refresh": "$OPENAI_CODEX_REFRESH",
      "expires": ${OPENAI_CODEX_EXPIRES:-1770420993133},
      "accountId": "${OPENAI_CODEX_ACCOUNT_ID:-default}"
    }
  }
}
EOF
  fi
  chown -R node:node /data 2>/dev/null || true
fi

# Use config from /data if exists
if [ -f "/data/clawdbot.json" ]; then
  export CLAWDBOT_CONFIG_PATH=/data/clawdbot.json
fi

export CLAWDBOT_STATE_DIR=/data

# Switch to node user and run the command
exec gosu node "$@"
