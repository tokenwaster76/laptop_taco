#!/usr/bin/env bash
# Post once to Bluesky via the ATProto API.
# Step 1: createSession to get accessJwt + did.
# Step 2: createRecord in app.bsky.feed.post with the status text.

set -euo pipefail

if [[ -z "${BLUESKY_HANDLE:-}" || -z "${BLUESKY_APP_PASSWORD:-}" ]]; then
  cat >&2 <<'EOF'
BLUESKY_HANDLE and/or BLUESKY_APP_PASSWORD is not set.

Create an app password at https://bsky.app/settings/app-passwords.
Do not use your real account password.

  export BLUESKY_HANDLE="you.bsky.social"
  export BLUESKY_APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
  ./marketing/scripts/post-bluesky.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/bluesky.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

text=$(sed "s|<REPO_URL>|$REPO_URL|g" "$src")

session_payload=$(HANDLE="$BLUESKY_HANDLE" PASS="$BLUESKY_APP_PASSWORD" python3 - <<'PY'
import json, os
print(json.dumps({"identifier": os.environ["HANDLE"], "password": os.environ["PASS"]}))
PY
)

session=$(curl -fsS -X POST https://bsky.social/xrpc/com.atproto.server.createSession \
  -H "Content-Type: application/json" \
  -d "$session_payload")

jwt=$(printf '%s' "$session" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("accessJwt",""))')
did=$(printf '%s' "$session" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("did",""))')

if [[ -z "$jwt" || -z "$did" ]]; then
  echo "Failed to create Bluesky session. Response:" >&2
  echo "$session" >&2
  exit 1
fi

created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

post_payload=$(DID="$did" TEXT="$text" CREATED_AT="$created_at" python3 - <<'PY'
import json, os
record = {
    "$type": "app.bsky.feed.post",
    "text": os.environ["TEXT"],
    "createdAt": os.environ["CREATED_AT"],
}
print(json.dumps({
    "repo": os.environ["DID"],
    "collection": "app.bsky.feed.post",
    "record": record,
}))
PY
)

resp=$(curl -fsS -X POST https://bsky.social/xrpc/com.atproto.repo.createRecord \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $jwt" \
  -d "$post_payload")

uri=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("uri",""))' || true)

if [[ -n "$uri" ]]; then
  rkey="${uri##*/}"
  echo "Bluesky post live: https://bsky.app/profile/$BLUESKY_HANDLE/post/$rkey"
else
  echo "Bluesky response:"
  echo "$resp"
fi
