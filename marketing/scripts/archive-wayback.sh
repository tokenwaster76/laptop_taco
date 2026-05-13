#!/usr/bin/env bash
# Submit the repo URL to the Wayback Machine for preservation/SEO.
# Best-effort. Wayback throttles aggressively; failure is soft.

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"
save="https://web.archive.org/save/$REPO_URL"

echo "Requesting Wayback snapshot of $REPO_URL ..."

# -L follows redirects (Wayback often returns a 302). -m caps the request.
# Use -w "%{http_code}" + -o /dev/null so we can detect throttles without
# letting curl's error output panic the caller.
code=$(curl -sS -L -m 30 -o /dev/null -w "%{http_code}" "$save" || echo "000")

case "$code" in
  200|301|302)
    echo "Wayback snapshot requested (HTTP $code)."
    echo "View archives: https://web.archive.org/web/*/$REPO_URL"
    ;;
  429|520|523|524)
    echo "Wayback is throttling (HTTP $code). Try again in a few minutes."
    ;;
  000)
    echo "Could not reach Wayback (network error). Skipping."
    ;;
  *)
    echo "Wayback responded with HTTP $code. Try the URL manually: $save"
    ;;
esac
