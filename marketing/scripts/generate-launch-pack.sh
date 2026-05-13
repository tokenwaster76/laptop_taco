#!/usr/bin/env bash
# Concatenate all marketing material into marketing/dist/launch-pack.md
# for easy copy-paste during launch day. Idempotent.

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"

env_file="$root/launch-config.env"

# Parse env file safely — never `source` it.  Accepts only simple
# KEY=value lines (KEY uppercase / underscores / digits).  Optional
# surrounding single or double quotes on the value are stripped.
# Comment lines and blanks are ignored.  This means a maliciously
# crafted .env file cannot execute shell code from inside this script.
parse_env_file() {
  local file="$1"
  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"
      if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
        value="${BASH_REMATCH[1]}"
      fi
      export "$key=$value"
    fi
  done < "$file"
}

# Only load the real launch-config.env. The .example.env contains
# placeholder values like YOUR_USERNAME/laptop-taco; loading those would
# leak the placeholder into the generated launch pack.
if [[ -f "$env_file" ]]; then
  parse_env_file "$env_file"
fi

REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"
PROJECT_NAME="${PROJECT_NAME:-Laptop Taco}"
TAGLINE="${TAGLINE:-For when your agent is cooking and you need to catch a bus.}"

dist_dir="$root/dist"
out="$dist_dir/launch-pack.md"
mkdir -p "$dist_dir"

substitute() {
  sed "s|<REPO_URL>|$REPO_URL|g"
}

{
  echo "# ${PROJECT_NAME} launch pack"
  echo
  echo "_${TAGLINE}_"
  echo
  echo "Repo: $REPO_URL"
  echo
  echo "## Core copy"
  echo
  echo '```text'
  echo "People are walking around with half-open laptops so AI coding agents do not fall asleep mid-task."
  echo
  echo "So I made ${PROJECT_NAME} 🌮"
  echo
  echo "A tiny macOS CLI that keeps your agent command awake, watches the process, and tells you when it is done."
  echo
  echo "No app."
  echo "No account."
  echo "No cloud."
  echo "Just a responsible taco."
  echo
  echo "GitHub: $REPO_URL"
  echo '```'
  echo
  echo "## UTM links"
  echo
  echo '```text'
  "$here/make-utm-links.sh"
  echo '```'
  echo
  echo "## Post drafts"
  echo
  for f in \
    "$root/posts/x-thread.md" \
    "$root/posts/linkedin.md" \
    "$root/posts/bluesky.md" \
    "$root/posts/mastodon.md" \
    "$root/posts/hacker-news.md" \
    "$root/posts/reddit.md" \
    "$root/posts/product-hunt.md" \
    "$root/posts/devto-article.md" \
    "$root/posts/lobsters.md" \
    "$root/posts/discord.md" \
    "$root/posts/slack.md" \
    "$root/posts/threads.md" \
    "$root/posts/github-release.md"; do
    if [[ -f "$f" ]]; then
      echo "---"
      echo
      substitute < "$f"
      echo
    fi
  done
  echo "---"
  echo
  echo "## Launch checklist"
  echo
  if [[ -f "$root/launch-checklist.md" ]]; then
    substitute < "$root/launch-checklist.md"
  fi
} > "$out"

echo "Wrote $out ($(wc -l < "$out" | tr -d ' ') lines)"
