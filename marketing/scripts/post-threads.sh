#!/usr/bin/env bash
# Post once to Meta's Threads via the official Threads API.
# Two-step: create container, then publish it.

set -euo pipefail

if [[ -z "${THREADS_ACCESS_TOKEN:-}" || -z "${THREADS_USER_ID:-}" ]]; then
  cat >&2 <<'EOF'
THREADS_ACCESS_TOKEN and/or THREADS_USER_ID is not set.

One-time setup at https://developers.facebook.com/apps:
  1. Create or pick an app, add the "Threads API" product.
  2. Generate a long-lived user access token via the OAuth flow.
  3. Find your Threads user ID (the API exposes it at /v1.0/me).

  export THREADS_ACCESS_TOKEN="THxxxxxxxxxxxxxxxx"
  export THREADS_USER_ID="123456789"
  ./marketing/scripts/post-threads.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/threads.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

text=$(sed "s|<REPO_URL>|$REPO_URL|g" "$src")

api="https://graph.threads.net/v1.0/$THREADS_USER_ID"

# Step 1: create the container.
container=$(curl -fsS -X POST "$api/threads" \
  --data-urlencode "media_type=TEXT" \
  --data-urlencode "text=$text" \
  --data-urlencode "access_token=$THREADS_ACCESS_TOKEN")

container_id=$(printf '%s' "$container" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("id",""))')

if [[ -z "$container_id" ]]; then
  echo "Threads container creation failed. Response:" >&2
  echo "$container" >&2
  exit 1
fi

# Step 2: publish.
publish=$(curl -fsS -X POST "$api/threads_publish" \
  --data-urlencode "creation_id=$container_id" \
  --data-urlencode "access_token=$THREADS_ACCESS_TOKEN")

post_id=$(printf '%s' "$publish" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("id",""))')

if [[ -n "$post_id" ]]; then
  echo "Threads post live (id=$post_id)."
else
  echo "Threads publish response:"
  echo "$publish"
  exit 1
fi
