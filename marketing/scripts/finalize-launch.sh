#!/usr/bin/env bash
# One-shot launch orchestrator.  Does every settings-page click the GitHub UI
# would otherwise require, in 10 seconds, given a single GITHUB_TOKEN PAT.
#
# Steps (all idempotent — re-running is safe):
#   1. Set default branch to main
#   2. Sync description + homepage + topics
#   3. Enable GitHub Pages from /docs on main
#   4. Create release v0.1.0  (fires .github/workflows/auto-announce.yml)
#
# Token:
#   Create a fine-grained PAT scoped to tokenwaster76/laptop_taco with:
#     Administration: Read & Write
#     Contents:       Read & Write
#     Metadata:       Read & Write
#     Pages:          Read & Write
#   https://github.com/settings/personal-access-tokens/new

set -euo pipefail

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
GITHUB_TOKEN is not set.

Create a fine-grained PAT at:
  https://github.com/settings/personal-access-tokens/new

Required Repository permissions:
  - Administration: Read & Write
  - Contents:       Read & Write
  - Metadata:       Read & Write
  - Pages:          Read & Write

Then run:
  export GITHUB_TOKEN="github_pat_xxxxxxxx"
  ./marketing/scripts/finalize-launch.sh
EOF
  exit 1
fi

OWNER="${GITHUB_OWNER:-tokenwaster76}"
REPO="${GITHUB_REPO:-laptop_taco}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
api="https://api.github.com/repos/$OWNER/$REPO"
H_AUTH="Authorization: Bearer $GITHUB_TOKEN"
H_ACCEPT="Accept: application/vnd.github+json"

step() { printf '\n\033[1;33m=== %s ===\033[0m\n' "$*"; }
say() { printf '  %s\n' "$*"; }

# --- 1. Default branch -> main ---------------------------------------------
step "Set default branch to $DEFAULT_BRANCH"
resp=$(curl -fsS --max-time 30 -X PATCH "$api" \
  -H "$H_AUTH" -H "$H_ACCEPT" \
  -d "{\"default_branch\":\"$DEFAULT_BRANCH\"}")
current=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("default_branch",""))')
say "default_branch = ${current}"

# --- 2. Description, homepage, topics --------------------------------------
step "Sync description + homepage + topics"
here="$(cd "$(dirname "$0")" && pwd)"
GITHUB_TOKEN="$GITHUB_TOKEN" GITHUB_OWNER="$OWNER" GITHUB_REPO="$REPO" \
  "$here/set-repo-metadata.sh"

# --- 3. GitHub Pages -------------------------------------------------------
step "Enable GitHub Pages from /docs on $DEFAULT_BRANCH"
code=$(curl -sS --max-time 30 -o /tmp/pages_resp.json -w "%{http_code}" \
  -X POST "$api/pages" \
  -H "$H_AUTH" -H "$H_ACCEPT" \
  -d "{\"source\":{\"branch\":\"$DEFAULT_BRANCH\",\"path\":\"/docs\"}}" || echo "000")
case "$code" in
  201)
    say "Pages enabled. URL will appear at https://${OWNER}.github.io/${REPO} once the build finishes."
    ;;
  409)
    say "Pages already enabled. Updating source to $DEFAULT_BRANCH/docs..."
    curl -fsS --max-time 30 -X PUT "$api/pages" \
      -H "$H_AUTH" -H "$H_ACCEPT" \
      -d "{\"source\":{\"branch\":\"$DEFAULT_BRANCH\",\"path\":\"/docs\"}}" >/dev/null
    say "Pages source = $DEFAULT_BRANCH/docs"
    ;;
  *)
    say "Pages enable returned HTTP $code (continuing). Response:"
    cat /tmp/pages_resp.json
    echo
    ;;
esac

# --- 4. Release v0.1.0 (fires auto-announce) -------------------------------
step "Create release v0.1.0 (fires auto-announce.yml)"
GITHUB_TOKEN="$GITHUB_TOKEN" GITHUB_OWNER="$OWNER" GITHUB_REPO="$REPO" \
  RELEASE_TARGET="$DEFAULT_BRANCH" \
  "$here/create-github-release.sh"

# --- Done ------------------------------------------------------------------
step "Launch finalized"
cat <<EOF

  Repo:         https://github.com/${OWNER}/${REPO}
  Actions:      https://github.com/${OWNER}/${REPO}/actions
  Auto-announce: https://github.com/${OWNER}/${REPO}/actions/workflows/auto-announce.yml
  Releases:     https://github.com/${OWNER}/${REPO}/releases
  Pages:        https://${OWNER}.github.io/${REPO}

Still manual (no public API exists):
  - Convert marketing/assets/*.svg -> PNG, upload via Settings -> Social
    preview and https://github.com/settings/profile
  - Create the tokenwaster76/tokenwaster76 profile repo using the content
    from marketing/profile-readme.md
  - HN / Lobsters / Product Hunt / Indie Hackers via
    ./marketing/scripts/open-submit-tabs.sh on your Mac
EOF
