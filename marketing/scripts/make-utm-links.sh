#!/usr/bin/env bash
# Print UTM-tagged share links for each launch channel.
# Usage:
#   REPO_URL=https://github.com/you/your-repo ./make-utm-links.sh
#   (or just run with no env to use the project default)

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"
CAMPAIGN="${CAMPAIGN:-laptop_taco_launch}"

channels=(x linkedin bluesky mastodon hackernews reddit producthunt devto)

for ch in "${channels[@]}"; do
  printf '%-12s %s?utm_source=%s&utm_medium=social&utm_campaign=%s\n' \
    "${ch}:" "$REPO_URL" "$ch" "$CAMPAIGN"
done
