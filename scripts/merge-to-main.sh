#!/usr/bin/env bash
# Merge any feature branch into main with a non-fast-forward merge commit.
# Handles the standard flow: feature -> main, push, optional delete of source.
#
# Usage:
#   ./scripts/merge-to-main.sh              # merge the current branch
#   ./scripts/merge-to-main.sh feature/x    # merge a named branch
#   MAIN_BRANCH=trunk ./scripts/merge-to-main.sh   # override the target

set -euo pipefail

BRANCH="${1:-$(git branch --show-current)}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

# --- Pre-flight checks -----------------------------------------------------
if [[ -z "$BRANCH" ]]; then
  echo "Could not determine current branch. Pass one as an argument." >&2
  exit 1
fi

if [[ "$BRANCH" == "$MAIN_BRANCH" ]]; then
  echo "Refusing to merge $MAIN_BRANCH into itself. Pass a feature branch." >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is dirty. Commit, stash, or discard your changes first:" >&2
  git status --short >&2
  exit 1
fi

# --- Fetch -----------------------------------------------------------------
echo "Fetching origin..."
git fetch --prune origin

if ! git rev-parse --verify --quiet "$BRANCH" >/dev/null && \
   ! git rev-parse --verify --quiet "origin/$BRANCH" >/dev/null; then
  echo "Branch '$BRANCH' not found locally or on origin." >&2
  exit 1
fi

if ! git rev-parse --verify --quiet "origin/$MAIN_BRANCH" >/dev/null; then
  echo "Cannot find origin/$MAIN_BRANCH." >&2
  exit 1
fi

SOURCE_SHA=$(git rev-parse "$BRANCH" 2>/dev/null || git rev-parse "origin/$BRANCH")

# --- Show what's about to happen -------------------------------------------
ahead=$(git rev-list --count "origin/$MAIN_BRANCH..$SOURCE_SHA")
behind=$(git rev-list --count "$SOURCE_SHA..origin/$MAIN_BRANCH")

if (( ahead == 0 )); then
  echo "Nothing to merge: '$BRANCH' is not ahead of origin/$MAIN_BRANCH."
  if (( behind > 0 )); then
    echo "  (It is $behind commit(s) behind origin/$MAIN_BRANCH.)"
    echo "  Consider: git checkout $BRANCH && git pull origin $MAIN_BRANCH"
    echo "  Or just delete it: git push origin --delete $BRANCH"
  fi
  exit 0
fi

printf '\n\033[1;33m=== About to merge ===\033[0m\n'
echo "  source:  $BRANCH ($(git rev-parse --short "$SOURCE_SHA"))"
echo "  target:  $MAIN_BRANCH ($(git rev-parse --short "origin/$MAIN_BRANCH"))"
echo "  ahead:   $ahead commit(s)"
echo "  behind:  $behind commit(s)"
echo
echo "Commits that will land on $MAIN_BRANCH:"
git log --oneline "origin/$MAIN_BRANCH..$SOURCE_SHA"
echo

read -r -p "Proceed with merge and push? [y/N] " yn
[[ "$yn" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# --- Do the merge ----------------------------------------------------------
git checkout "$MAIN_BRANCH"
git pull --ff-only origin "$MAIN_BRANCH"

# --no-ff so the merge stays visible in the history (matches GitHub PR style).
git merge --no-ff "$SOURCE_SHA" -m "Merge $BRANCH into $MAIN_BRANCH"

git push origin "$MAIN_BRANCH"

printf '\n\033[1;32m✅ Merged.\033[0m %s now at %s\n' \
  "$MAIN_BRANCH" "$(git rev-parse --short HEAD)"

# --- Optional source-branch cleanup ----------------------------------------
echo
read -r -p "Delete '$BRANCH' (local + remote)? [y/N] " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  git branch -d "$BRANCH" 2>/dev/null || git branch -D "$BRANCH" 2>/dev/null || true
  git push origin --delete "$BRANCH" 2>/dev/null || true
  echo "🗑  Deleted '$BRANCH'."
else
  echo "Kept '$BRANCH'. Delete later with:"
  echo "  git branch -d $BRANCH"
  echo "  git push origin --delete $BRANCH"
fi
