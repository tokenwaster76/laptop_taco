#!/usr/bin/env bash
# Open pre-filled submit forms for the 4 platforms that have no public
# submission API (HN, Lobsters, Product Hunt, Indie Hackers), plus pre-filled
# share-intent URLs for X/Bluesky/LinkedIn/Threads/Mastodon as a fallback for
# whichever automated posters you haven't configured yet.
#
# On macOS, every URL is opened in your default browser via `open`.
# On other platforms, the URLs are printed so you can paste them.

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"
HN_TITLE="Show HN: Laptop Taco – keep your Mac awake while coding agents run"
LOBSTERS_TITLE="Laptop Taco: a tiny macOS caffeinate wrapper for long-running coding agents"
LOBSTERS_TAGS="release,unix,mac,show"

short_pitch="People are walking around with half-open laptops so AI coding agents don't fall asleep mid-task. So I made Laptop Taco 🌮 — a tiny macOS CLI for long-running agents."

urlencode() {
  python3 -c 'import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}

text_enc=$(urlencode "$short_pitch $REPO_URL")
text_only_enc=$(urlencode "$short_pitch")
url_enc=$(urlencode "$REPO_URL")
hn_title_enc=$(urlencode "$HN_TITLE")
lob_title_enc=$(urlencode "$LOBSTERS_TITLE")
lob_tags_enc=$(urlencode "$LOBSTERS_TAGS")

# 4 platforms with no submit API — pre-filled forms.
no_api_urls=(
  "https://news.ycombinator.com/submitlink?u=$url_enc&t=$hn_title_enc"
  "https://lobste.rs/stories/new?url=$url_enc&title=$lob_title_enc&tags=$lob_tags_enc"
  "https://www.producthunt.com/posts/new"
  "https://www.indiehackers.com/post/new"
)

# Pre-filled share-intent URLs (fallback if you haven't configured the API)
fallback_urls=(
  "https://twitter.com/intent/tweet?text=$text_enc"
  "https://bsky.app/intent/compose?text=$text_enc"
  "https://www.linkedin.com/sharing/share-offsite/?url=$url_enc"
  "https://threads.net/intent/post?text=$text_enc"
  "https://toot.kytta.dev/?text=$text_enc"
)

# The repo itself, so you can grab the latest stats while you launch.
extras=("$REPO_URL")

all_urls=("${no_api_urls[@]}" "${fallback_urls[@]}" "${extras[@]}")

if [[ "$(uname)" == "Darwin" ]]; then
  for u in "${all_urls[@]}"; do
    open "$u" || true
  done
  echo "Opened ${#all_urls[@]} tabs."
  echo "First four are submit forms (HN / Lobsters / Product Hunt / Indie Hackers)."
  echo "Next five are share-intent fallbacks (X / Bluesky / LinkedIn / Threads / Mastodon)."
else
  echo "Not macOS — printing URLs instead. Paste into your browser."
  echo
  echo "## Submit forms (no API — manual click)"
  for u in "${no_api_urls[@]}"; do
    echo "  $u"
  done
  echo
  echo "## Share-intent fallbacks (use these if you haven't configured the API poster)"
  for u in "${fallback_urls[@]}"; do
    echo "  $u"
  done
  echo
  echo "## Repo"
  for u in "${extras[@]}"; do
    echo "  $u"
  done
fi
