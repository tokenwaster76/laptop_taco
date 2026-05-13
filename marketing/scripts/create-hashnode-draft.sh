#!/usr/bin/env bash
# Create a Hashnode draft via GraphQL. Never publishes live.

set -euo pipefail

if [[ -z "${HASHNODE_API_TOKEN:-}" || -z "${HASHNODE_PUBLICATION_ID:-}" ]]; then
  cat >&2 <<'EOF'
HASHNODE_API_TOKEN and/or HASHNODE_PUBLICATION_ID is not set.

Get a token at https://hashnode.com/settings/developer (Personal Access Token).
Find your publication ID under your blog's Hashnode settings.

  export HASHNODE_API_TOKEN="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  export HASHNODE_PUBLICATION_ID="00000000000000000000000a"
  ./marketing/scripts/create-hashnode-draft.sh
EOF
  exit 1
fi

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/.." && pwd)"
src="$root/posts/devto-article.md"
REPO_URL="${REPO_URL:-https://github.com/tokenwaster76/laptop_taco}"

if [[ ! -f "$src" ]]; then
  echo "Source post not found: $src" >&2
  exit 1
fi

title=$(awk '/^title:/{sub(/^title:[[:space:]]*/,""); print; exit}' "$src")
body=$(awk 'BEGIN{c=0} /^---[[:space:]]*$/{c++; next} c>=2{print}' "$src" \
       | sed "s|<REPO_URL>|$REPO_URL|g")

payload=$(
  TITLE="$title" BODY="$body" PUB="$HASHNODE_PUBLICATION_ID" python3 - <<'PY'
import json, os
mutation = """
mutation Draft($input: CreateDraftInput!) {
  createDraft(input: $input) { draft { id slug } }
}
""".strip()
variables = {
    "input": {
        "title": os.environ["TITLE"].strip(),
        "contentMarkdown": os.environ["BODY"],
        "publicationId": os.environ["PUB"],
    }
}
print(json.dumps({"query": mutation, "variables": variables}))
PY
)

resp=$(curl -fsS --max-time 60 -X POST https://gql.hashnode.com \
  -H "Content-Type: application/json" \
  -H "Authorization: $HASHNODE_API_TOKEN" \
  -d "$payload")

slug=$(printf '%s' "$resp" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("data",{}).get("createDraft",{}).get("draft",{}).get("slug",""))' || true)

if [[ -n "$slug" ]]; then
  echo "Hashnode draft created. Slug: $slug"
  echo "Open https://hashnode.com/drafts to edit and publish."
else
  echo "Hashnode response:"
  echo "$resp"
fi
