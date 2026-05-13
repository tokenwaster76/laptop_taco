#!/usr/bin/env bash
# Sync the repo's description, homepage, and topics. Idempotent.

set -euo pipefail

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
GITHUB_TOKEN is not set.

Create a fine-grained PAT scoped to this repo with:
  Contents: Read
  Metadata: Read & Write
  Administration: Read & Write (for topics)

  export GITHUB_TOKEN="github_pat_xxxxxxxx"
  ./marketing/scripts/set-repo-metadata.sh
EOF
  exit 1
fi

OWNER="${GITHUB_OWNER:-tokenwaster76}"
REPO="${GITHUB_REPO:-laptop_taco}"
DESC="${REPO_DESCRIPTION:-🌮 Tiny macOS CLI that keeps your Mac awake while AI coding agents cook.}"
HOMEPAGE="${REPO_HOMEPAGE:-https://github.com/$OWNER/$REPO}"

topics=(
  macos
  cli
  bash
  caffeinate
  ai
  developer-tools
  productivity
  claude-code
  codex
  coding-agents
)

api="https://api.github.com/repos/$OWNER/$REPO"

# Description + homepage
patch=$(DESC="$DESC" HOMEPAGE="$HOMEPAGE" python3 -c 'import os,json;print(json.dumps({"description":os.environ["DESC"],"homepage":os.environ["HOMEPAGE"]}))')

curl -fsS --max-time 60 -X PATCH "$api" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "$patch" >/dev/null
echo "Updated description + homepage."

# Topics
topics_payload=$(printf '%s\n' "${topics[@]}" | python3 -c 'import sys,json;print(json.dumps({"names":[l.strip() for l in sys.stdin if l.strip()]}))')

curl -fsS --max-time 60 -X PUT "$api/topics" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d "$topics_payload" >/dev/null
echo "Updated topics: ${topics[*]}"
