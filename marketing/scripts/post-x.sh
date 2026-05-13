#!/usr/bin/env bash
# Post a 5-tweet thread to X / Twitter via the v2 API.
# REQUIRES PAID TIER. X's Free tier severely caps writes; Basic ($100/mo)
# is the entry point for thread posting. If you don't want to pay, skip
# this script and use the tweet-intent URL opener in open-submit-tabs.sh.
#
# Auth: OAuth 1.0a user context (most common for posting on behalf of yourself).

set -euo pipefail

req=(X_API_KEY X_API_SECRET X_ACCESS_TOKEN X_ACCESS_TOKEN_SECRET)
for v in "${req[@]}"; do
  if [[ -z "${!v:-}" ]]; then
    cat >&2 <<EOF
$v is not set.

X's posting API requires Basic tier (\$100/mo as of 2026) and OAuth 1.0a
user-context credentials. To get them:
  1. Subscribe to X API Basic at https://developer.x.com/en/portal/products
  2. Create a project + app, enable "Read and write" permissions.
  3. Generate consumer keys (API Key + Secret) and user access tokens.

  export X_API_KEY="..."
  export X_API_SECRET="..."
  export X_ACCESS_TOKEN="..."
  export X_ACCESS_TOKEN_SECRET="..."
  ./marketing/scripts/post-x.sh

If you'd rather not pay, run ./marketing/scripts/open-submit-tabs.sh
to open a pre-filled tweet compose window instead.
EOF
    exit 1
  fi
done

if ! python3 -c 'import requests_oauthlib' >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Python module 'requests-oauthlib' is required for OAuth 1.0a signing.
Install it once:

  pip install --user requests-oauthlib

Then re-run this script.
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/x-thread.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

# Extract each post (separated by '**Post N**' headers + the surrounding ---).
SRC="$src" REPO_URL="$REPO_URL" python3 - <<'PY'
import os, re, sys, json
src = open(os.environ["SRC"]).read().replace("<REPO_URL>", os.environ["REPO_URL"])
# Split on **Post N** headers
chunks = re.split(r"(?m)^\*\*Post\s+\d+\*\*\s*$", src)
# First chunk before any **Post 1** is the file preamble; drop it.
posts = []
for c in chunks[1:]:
    # Strip leading/trailing whitespace and the '---' rulers
    body = re.sub(r"^\s*---\s*$", "", c, flags=re.M).strip()
    if body:
        posts.append(body)
if not posts:
    print("No posts parsed from x-thread.md", file=sys.stderr)
    sys.exit(1)
print(json.dumps(posts))
PY

# Re-run extraction and pipe to a bash array via a tempfile.
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
SRC="$src" REPO_URL="$REPO_URL" python3 - >"$tmp" <<'PY'
import os, re, json
src = open(os.environ["SRC"]).read().replace("<REPO_URL>", os.environ["REPO_URL"])
chunks = re.split(r"(?m)^\*\*Post\s+\d+\*\*\s*$", src)
posts = []
for c in chunks[1:]:
    body = re.sub(r"^\s*---\s*$", "", c, flags=re.M).strip()
    if body:
        posts.append(body)
print(json.dumps(posts))
PY

# Post the thread, replying each next tweet to the previous.
X_API_KEY="$X_API_KEY" X_API_SECRET="$X_API_SECRET" \
X_ACCESS_TOKEN="$X_ACCESS_TOKEN" X_ACCESS_TOKEN_SECRET="$X_ACCESS_TOKEN_SECRET" \
POSTS_FILE="$tmp" python3 - <<'PY'
import os, json, sys
from requests_oauthlib import OAuth1Session

posts = json.load(open(os.environ["POSTS_FILE"]))
oauth = OAuth1Session(
    os.environ["X_API_KEY"],
    client_secret=os.environ["X_API_SECRET"],
    resource_owner_key=os.environ["X_ACCESS_TOKEN"],
    resource_owner_secret=os.environ["X_ACCESS_TOKEN_SECRET"],
)

prev_id = None
for i, text in enumerate(posts, 1):
    payload = {"text": text}
    if prev_id:
        payload["reply"] = {"in_reply_to_tweet_id": prev_id}
    resp = oauth.post("https://api.x.com/2/tweets", json=payload)
    if resp.status_code >= 400:
        print(f"X tweet #{i} failed (HTTP {resp.status_code}):", file=sys.stderr)
        print(resp.text, file=sys.stderr)
        sys.exit(1)
    data = resp.json().get("data", {})
    tid = data.get("id")
    print(f"Posted #{i}: https://x.com/i/web/status/{tid}")
    prev_id = tid
PY

echo "X thread posted."
