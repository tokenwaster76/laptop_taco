#!/usr/bin/env bash
# Concatenate all marketing material into marketing/dist/launch-pack.md
# for easy copy-paste during launch day. Idempotent.

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"

env_file="$root/launch-config.env"
example_env="$root/launch-config.example.env"

if [[ -f "$env_file" ]]; then
  # shellcheck disable=SC1090
  source "$env_file"
elif [[ -f "$example_env" ]]; then
  # shellcheck disable=SC1090
  source "$example_env"
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
