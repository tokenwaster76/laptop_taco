#!/usr/bin/env bash
# Post once to LinkedIn via the UGC Posts API (REST v2).
# Requires a LinkedIn app with w_member_social scope and an access token
# captured via get-linkedin-token.sh (or any standard OAuth dance).

set -euo pipefail

if [[ -z "${LINKEDIN_ACCESS_TOKEN:-}" || -z "${LINKEDIN_AUTHOR_URN:-}" ]]; then
  cat >&2 <<'EOF'
LINKEDIN_ACCESS_TOKEN and/or LINKEDIN_AUTHOR_URN is not set.

One-time setup:
  1. Create an app at https://www.linkedin.com/developers/apps
  2. Add the "Share on LinkedIn" + "Sign In with LinkedIn using OpenID Connect" products
  3. Request the w_member_social scope
  4. Run: ./marketing/scripts/get-linkedin-token.sh
  5. Capture LINKEDIN_ACCESS_TOKEN (valid ~60 days) and LINKEDIN_AUTHOR_URN

  export LINKEDIN_ACCESS_TOKEN="AQXxxxxxxxxxxxxxxx"
  export LINKEDIN_AUTHOR_URN="urn:li:person:xxxxxxxx"
  ./marketing/scripts/post-linkedin.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/linkedin.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

# Strip the leading H1 + helper comment if present — LinkedIn doesn't render markdown.
body=$(awk '
  /^# / { in_meta=1; next }
  /^---/ && in_meta==1 { in_meta=0; next }
  in_meta { next }
  { print }
' "$src" | sed "s|<REPO_URL>|$REPO_URL|g" | sed 's/^[[:space:]]*$//' | awk 'NF>0 || prev_blank==0 { print; prev_blank = (NF==0) }')

payload=$(URN="$LINKEDIN_AUTHOR_URN" TEXT="$body" python3 - <<'PY'
import json, os
print(json.dumps({
    "author": os.environ["URN"],
    "lifecycleState": "PUBLISHED",
    "specificContent": {
        "com.linkedin.ugc.ShareContent": {
            "shareCommentary": {"text": os.environ["TEXT"]},
            "shareMediaCategory": "NONE",
        }
    },
    "visibility": {"com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"},
}))
PY
)

resp=$(curl -fsS --max-time 60 -X POST https://api.linkedin.com/v2/ugcPosts \
  -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" \
  -H "X-Restli-Protocol-Version: 2.0.0" \
  -H "Content-Type: application/json" \
  -d "$payload")

id=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("id",""))' || true)

if [[ -n "$id" ]]; then
  echo "LinkedIn post live: https://www.linkedin.com/feed/update/$id"
else
  echo "LinkedIn response:"
  echo "$resp"
  exit 1
fi
