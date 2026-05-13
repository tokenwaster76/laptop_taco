#!/usr/bin/env bash
# Post once to Discord via your own channel webhook URL.
# Only run this against a webhook in a server you own/have permission to post in.

set -euo pipefail

if [[ -z "${DISCORD_WEBHOOK_URL:-}" ]]; then
  cat >&2 <<'EOF'
DISCORD_WEBHOOK_URL is not set.

Create a webhook in your own Discord server:
Server Settings -> Integrations -> Webhooks -> New Webhook. Copy the URL.

  export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/.../..."
  ./marketing/scripts/post-discord.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/discord.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

content=$(sed "s|<REPO_URL>|$REPO_URL|g" "$src")

payload=$(CONTENT="$content" python3 -c 'import os,json;print(json.dumps({"content": os.environ["CONTENT"]}))')

curl -fsS -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload" >/dev/null

echo "Discord post sent."
