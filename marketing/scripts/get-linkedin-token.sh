#!/usr/bin/env bash
# One-time LinkedIn OAuth helper. Prints the URL you need to visit and then
# exchanges the returned ?code= for an access token.
#
# Usage:
#   export LINKEDIN_CLIENT_ID="78yyy..."
#   export LINKEDIN_CLIENT_SECRET="ZZZ..."
#   ./marketing/scripts/get-linkedin-token.sh

set -euo pipefail

REDIRECT_URI="${LINKEDIN_REDIRECT_URI:-http://localhost:8080/callback}"

if [[ -z "${LINKEDIN_CLIENT_ID:-}" || -z "${LINKEDIN_CLIENT_SECRET:-}" ]]; then
  cat >&2 <<EOF
LINKEDIN_CLIENT_ID and/or LINKEDIN_CLIENT_SECRET is not set.

One-time setup:
  1. Create an app at https://www.linkedin.com/developers/apps
  2. Under Auth -> OAuth 2.0 settings, add this redirect URL:
       $REDIRECT_URI
  3. Under Products, request "Share on LinkedIn" + "Sign In with LinkedIn using OpenID Connect"
  4. Copy Client ID and Client Secret from the Auth tab, then:

       export LINKEDIN_CLIENT_ID="78yyy..."
       export LINKEDIN_CLIENT_SECRET="ZZZ..."
       ./marketing/scripts/get-linkedin-token.sh
EOF
  exit 1
fi

STATE="$(date +%s%N)"
SCOPE="w_member_social%20openid%20profile"
auth_url="https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=$LINKEDIN_CLIENT_ID&redirect_uri=$(python3 -c "import urllib.parse,os;print(urllib.parse.quote(os.environ['REDIRECT_URI'], safe=''))" REDIRECT_URI="$REDIRECT_URI")&state=$STATE&scope=$SCOPE"

echo "Step 1: open this URL in a browser, approve, and copy the 'code' query param from the redirect:"
echo
echo "  $auth_url"
echo

read -r -p "Paste the code here: " code

if [[ -z "$code" ]]; then
  echo "No code supplied. Aborting." >&2
  exit 1
fi

resp=$(curl -fsS --max-time 60 -X POST https://www.linkedin.com/oauth/v2/accessToken \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "code=$code" \
  --data-urlencode "redirect_uri=$REDIRECT_URI" \
  --data-urlencode "client_id=$LINKEDIN_CLIENT_ID" \
  --data-urlencode "client_secret=$LINKEDIN_CLIENT_SECRET")

access_token=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("access_token",""))')
expires_in=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("expires_in",""))')

if [[ -z "$access_token" ]]; then
  echo "Token exchange failed. Response:" >&2
  echo "$resp" >&2
  exit 1
fi

# Fetch the author URN via userinfo (OpenID).
info=$(curl -fsS --max-time 60 https://api.linkedin.com/v2/userinfo \
  -H "Authorization: Bearer $access_token")
sub=$(printf '%s' "$info" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("sub",""))')

echo
echo "Success. Save these (they belong in your local .env or GitHub Actions secrets):"
echo
echo "  export LINKEDIN_ACCESS_TOKEN=\"$access_token\""
echo "  export LINKEDIN_AUTHOR_URN=\"urn:li:person:$sub\""
echo
echo "Token expires in approximately $expires_in seconds. Refresh with this script when it lapses."
