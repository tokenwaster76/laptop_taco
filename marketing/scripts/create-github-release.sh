#!/usr/bin/env bash
# Create a GitHub release for the current repo. Idempotent: if the
# tag's release already exists, prints a friendly message and exits 0.

set -euo pipefail

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
GITHUB_TOKEN is not set.

Create a fine-grained PAT at https://github.com/settings/personal-access-tokens
scoped to this repo with: Contents (Read & Write), Metadata (Read).

  export GITHUB_TOKEN="github_pat_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  ./marketing/scripts/create-github-release.sh
EOF
  exit 1
fi

OWNER="${GITHUB_OWNER:-tokenwaster76}"
REPO="${GITHUB_REPO:-laptop_taco}"
TAG="${RELEASE_TAG:-v0.1.0}"
NAME="${RELEASE_NAME:-Laptop Taco 🌮 ${TAG}}"
TARGET="${RELEASE_TARGET:-main}"

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
body_file="$root/posts/github-release.md"
REPO_URL="${REPO_URL:-https://github.com/$OWNER/$REPO}"

if [[ ! -f "$body_file" ]]; then
  echo "Release body file not found: $body_file" >&2
  exit 1
fi

body=$(sed "s|<REPO_URL>|$REPO_URL|g" "$body_file")

api="https://api.github.com/repos/$OWNER/$REPO/releases"

# Idempotency: check whether a release for this tag already exists.
existing=$(curl -fsS \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "$api/tags/$TAG" 2>/dev/null || true)

if printf '%s' "$existing" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    sys.exit(0 if d.get("id") else 1)
except Exception:
    sys.exit(1)' >/dev/null 2>&1; then
  url=$(printf '%s' "$existing" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("html_url",""))')
  echo "Release for tag $TAG already exists: $url"
  exit 0
fi

payload=$(TAG="$TAG" NAME="$NAME" BODY="$body" TARGET="$TARGET" python3 - <<'PY'
import json, os
print(json.dumps({
  "tag_name": os.environ["TAG"],
  "target_commitish": os.environ["TARGET"],
  "name": os.environ["NAME"],
  "body": os.environ["BODY"],
  "draft": False,
  "prerelease": False,
}))
PY
)

resp=$(curl -fsS -X POST "$api" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "$payload")

url=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("html_url",""))' || true)

if [[ -n "$url" ]]; then
  echo "Release $TAG published: $url"
else
  echo "GitHub response:"
  echo "$resp"
  exit 1
fi
