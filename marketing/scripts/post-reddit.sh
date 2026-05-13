#!/usr/bin/env bash
# Post once to a single subreddit via the Reddit OAuth API. Refuses to:
#   - run without REDDIT_AUTO_POST_OPT_IN=true (anti-foot-gun)
#   - run more than once per minute (rate guard)
#   - target more than one subreddit per invocation (no cross-posting)
#
# Reddit's spam filter is aggressive. Read each sub's rules before pointing
# this at it. Account age + karma + a comment-to-self-promo ratio of >10:1
# is the baseline.

set -euo pipefail

if [[ "${REDDIT_AUTO_POST_OPT_IN:-}" != "true" ]]; then
  cat >&2 <<'EOF'
REDDIT_AUTO_POST_OPT_IN is not "true".

This script will not post to Reddit unless you explicitly opt in for this
specific launch by setting REDDIT_AUTO_POST_OPT_IN=true. This guard exists
because cross-posting + automation is the single fastest way to get
shadow-banned.

  export REDDIT_AUTO_POST_OPT_IN=true
  export REDDIT_SUBREDDIT="SideProject"   # one sub. one.
  export REDDIT_CLIENT_ID="..."
  export REDDIT_CLIENT_SECRET="..."
  export REDDIT_USERNAME="..."
  export REDDIT_PASSWORD="..."
  ./marketing/scripts/post-reddit.sh
EOF
  exit 1
fi

for var in REDDIT_CLIENT_ID REDDIT_CLIENT_SECRET REDDIT_USERNAME REDDIT_PASSWORD REDDIT_SUBREDDIT; do
  if [[ -z "${!var:-}" ]]; then
    echo "$var is not set. See ./marketing/scripts/post-reddit.sh header for instructions." >&2
    exit 1
  fi
done

# Single-sub guard
if [[ "$REDDIT_SUBREDDIT" == *,* || "$REDDIT_SUBREDDIT" == *+* || "$REDDIT_SUBREDDIT" == *\ * ]]; then
  echo "REDDIT_SUBREDDIT must be a single subreddit name (no commas, no '+', no spaces). Got: $REDDIT_SUBREDDIT" >&2
  exit 1
fi

# Minute-rate guard via a marker file
state_dir="${TMPDIR:-/tmp}"
marker="$state_dir/.laptop_taco_reddit_last"
if [[ -f "$marker" ]]; then
  last=$(cat "$marker" 2>/dev/null || echo 0)
  now=$(date +%s)
  if (( now - last < 60 )); then
    echo "Refusing: posted to Reddit within the last 60 seconds. Wait a minute." >&2
    exit 1
  fi
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"
USER_AGENT="laptop-taco-launch/0.1.0 by ${REDDIT_USERNAME}"

# Extract the r/SideProject section from the reddit drafts file as the post.
src="$root/posts/reddit.md"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

title_re='^\*\*Title:\*\*[[:space:]]*(.+)$'
section_heading="## r/${REDDIT_SUBREDDIT}"

title=""
body=""
in_section=0
in_body=0
while IFS= read -r line; do
  if [[ "$line" == "$section_heading"* ]]; then
    in_section=1
    continue
  fi
  if (( in_section )) && [[ "$line" == "## "* ]] && [[ "$line" != "$section_heading"* ]]; then
    # next section started
    break
  fi
  if (( in_section )); then
    if [[ -z "$title" ]] && [[ "$line" =~ $title_re ]]; then
      title="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ "$line" == "**Body:**" ]]; then
      in_body=1
      continue
    fi
    if (( in_body )); then
      body+="$line"$'\n'
    fi
  fi
done < "$src"

if [[ -z "$title" || -z "$body" ]]; then
  echo "Could not find a draft for r/$REDDIT_SUBREDDIT in $src." >&2
  echo "Available drafts in this file:" >&2
  grep -E '^## r/' "$src" >&2 || true
  exit 1
fi

body=$(printf '%s' "$body" | sed "s|<REPO_URL>|$REPO_URL|g")

# Step 1: OAuth token via 'password' grant against the script-app endpoint.
token_resp=$(curl -fsS -X POST https://www.reddit.com/api/v1/access_token \
  --user "$REDDIT_CLIENT_ID:$REDDIT_CLIENT_SECRET" \
  -A "$USER_AGENT" \
  -d "grant_type=password&username=$REDDIT_USERNAME&password=$REDDIT_PASSWORD")

access_token=$(printf '%s' "$token_resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("access_token",""))')

if [[ -z "$access_token" ]]; then
  echo "Reddit token exchange failed. Response:" >&2
  echo "$token_resp" >&2
  exit 1
fi

# Step 2: submit a self-text post (kind=self) to the chosen sub.
resp=$(curl -fsS -X POST https://oauth.reddit.com/api/submit \
  -H "Authorization: Bearer $access_token" \
  -A "$USER_AGENT" \
  --data-urlencode "sr=$REDDIT_SUBREDDIT" \
  --data-urlencode "kind=self" \
  --data-urlencode "title=$title" \
  --data-urlencode "text=$body" \
  --data-urlencode "api_type=json" \
  --data-urlencode "sendreplies=true")

url=$(printf '%s' "$resp" | python3 -c 'import sys,json
try:
  d=json.load(sys.stdin)
  url=d.get("json",{}).get("data",{}).get("url","")
  print(url)
except Exception:
  print("")
')

date +%s > "$marker"

if [[ -n "$url" ]]; then
  echo "Reddit post live: $url"
else
  echo "Reddit response:"
  echo "$resp"
  exit 1
fi
