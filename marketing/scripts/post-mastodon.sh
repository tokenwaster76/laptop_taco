#!/usr/bin/env bash
# Post once to Mastodon via the standard /api/v1/statuses endpoint.
# One status, no thread support, no scheduling.

set -euo pipefail

if [[ -z "${MASTODON_INSTANCE:-}" || -z "${MASTODON_ACCESS_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
MASTODON_INSTANCE and/or MASTODON_ACCESS_TOKEN is not set.

To create a token: log in to your Mastodon instance, go to
Preferences -> Development -> New Application. Scopes needed: write:statuses.

  export MASTODON_INSTANCE="https://mastodon.social"
  export MASTODON_ACCESS_TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  ./marketing/scripts/post-mastodon.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/mastodon.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

status=$(sed "s|<REPO_URL>|$REPO_URL|g" "$src")

resp=$(curl -fsS -X POST "${MASTODON_INSTANCE%/}/api/v1/statuses" \
  -H "Authorization: Bearer $MASTODON_ACCESS_TOKEN" \
  --data-urlencode "status=$status")

url=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("url",""))' || true)

if [[ -n "$url" ]]; then
  echo "Mastodon post live: $url"
else
  echo "Mastodon response:"
  echo "$resp"
fi
