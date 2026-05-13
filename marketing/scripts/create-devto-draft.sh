#!/usr/bin/env bash
# Create a DEV.to article as a DRAFT (published: false).
# Never publishes live — a human still has to hit Publish in the dashboard.

set -euo pipefail

if [[ -z "${DEVTO_API_KEY:-}" ]]; then
  cat >&2 <<'EOF'
DEVTO_API_KEY is not set.

Get a key from https://dev.to/settings/extensions (DEV Community API Keys),
then run:

  export DEVTO_API_KEY="dev_xxxxxxxxxxxxxxxxxxxxxxxx"
  ./marketing/scripts/create-devto-draft.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/devto-article.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

# Extract front-matter title/tags, keep the rest as body_markdown.
title=$(awk '/^title:/{sub(/^title:[[:space:]]*/,""); print; exit}' "$src")
tags=$(awk '/^tags:/{sub(/^tags:[[:space:]]*/,""); print; exit}' "$src")

# Body is everything after the second `---` separator.
body=$(awk 'BEGIN{c=0} /^---[[:space:]]*$/{c++; next} c>=2{print}' "$src" \
       | sed "s|<REPO_URL>|$REPO_URL|g")

# Build the JSON payload safely. We rely on python3 for JSON encoding so
# titles / bodies with quotes don't break us. python3 ships everywhere we run.
payload=$(
  TITLE="$title" TAGS="$tags" BODY="$body" python3 - <<'PY'
import json, os
tags = [t.strip() for t in os.environ.get("TAGS", "").split(",") if t.strip()]
article = {
    "title": os.environ.get("TITLE", "").strip(),
    "body_markdown": os.environ.get("BODY", ""),
    "tags": tags,
    "published": False,
}
print(json.dumps({"article": article}))
PY
)

resp=$(curl -fsS -X POST https://dev.to/api/articles \
  -H "Content-Type: application/json" \
  -H "api-key: $DEVTO_API_KEY" \
  -d "$payload")

# Extract URL (and id) without jq.
url=$(printf '%s' "$resp" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("url",""))' || true)

if [[ -n "$url" ]]; then
  echo "DEV.to draft created: $url"
else
  echo "DEV.to response:"
  echo "$resp"
fi
