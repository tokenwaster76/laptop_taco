#!/usr/bin/env bash
# Post once to Slack via your own Incoming Webhook URL.
# Only run against a workspace where you have permission to post.

set -euo pipefail

if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
  cat >&2 <<'EOF'
SLACK_WEBHOOK_URL is not set.

Create an Incoming Webhook in your workspace:
https://api.slack.com/messaging/webhooks

  export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T.../B.../..."
  ./marketing/scripts/post-slack.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/slack.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

text=$(sed "s|<REPO_URL>|$REPO_URL|g" "$src")

payload=$(TEXT="$text" python3 -c 'import os,json;print(json.dumps({"text": os.environ["TEXT"]}))')

curl -fsS -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload" >/dev/null

echo "Slack post sent."
