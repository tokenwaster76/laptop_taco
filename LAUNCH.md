# Go-public checklist

This is the human-side checklist for flipping `tokenwaster76/laptop_taco` from private to public. The CI / repo-metadata side is automated — your job is the four things in §A that need a real browser and a real human click.

## A. Things only you can do (web UI, ~10 minutes)

> The MCP / API surface I had access to cannot flip repo visibility, can't reach your other repos, and can't reach `tokenwaster76/tokenwaster76`. These are clicks.

### 1. Verify CI is green on PR #1 before going public

1. https://github.com/tokenwaster76/laptop_taco/actions
2. Find the latest `macOS smoke test` run for branch `claude/create-laptop-taco-repo-Nx2HN`
3. All steps green? Good. Failing? Fix before going public — a failing badge on day 1 is bad first impression.

### 2. Make `laptop_taco` public

1. https://github.com/tokenwaster76/laptop_taco/settings
2. Scroll to the bottom — **Danger Zone**
3. Change repository visibility → Public
4. Type the confirmation, click through.

### 3. Make every *other* repo private

GitHub doesn't ship a bulk-visibility toggle, but the per-repo route is two clicks:

For each repo at https://github.com/tokenwaster76?tab=repositories:
1. Open it
2. Settings → Danger Zone → Change visibility → Private

If you'd rather batch it, install the `gh` CLI locally and run:

```bash
gh auth login
# list every public repo except laptop_taco, flip each to private
gh repo list tokenwaster76 --visibility public --limit 200 \
  --json nameWithOwner --jq '.[].nameWithOwner' \
  | grep -v '^tokenwaster76/laptop_taco$' \
  | xargs -I{} gh repo edit {} --visibility private
```

That command **excludes** `laptop_taco`. Read the list before piping if you have any repo you want to keep public other than laptop_taco.

### 4. Profile avatar (taco, matching the repo's visual language)

`marketing/assets/profile-avatar.svg` — 1024×1024 vector, dark canvas + amber ring + a flat-illustrated taco. No emoji-font dependency, so PNG conversion looks the same on any machine.

```bash
# librsvg
rsvg-convert -w 1024 -h 1024 marketing/assets/profile-avatar.svg \
  -o /tmp/avatar.png

# or Inkscape
inkscape marketing/assets/profile-avatar.svg \
  --export-type=png --export-filename=/tmp/avatar.png -w 1024 -h 1024
```

Upload at https://github.com/settings/profile → *Profile picture → Edit → Upload a photo* → pick `/tmp/avatar.png`.

GitHub crops to square automatically, but the SVG is already square so no cropping happens.

### 5. Profile README (renders on your profile page)

1. https://github.com/new
2. Repository name: `tokenwaster76` (exactly your username)
3. Public, tick "Add a README"
4. Open the new repo's README, paste the block from [`marketing/profile-readme.md`](marketing/profile-readme.md)
5. Commit

GitHub auto-renders it on your profile page within a minute.

Then **pin** `laptop_taco` from your profile:
1. https://github.com/tokenwaster76 → "Customize your pins" → tick `laptop_taco`.

## B. Things the automation does for you (once secrets are set)

Once `laptop_taco` is public:

### 1. Repo description + topics + homepage

Run `marketing/scripts/set-repo-metadata.sh` once. Requires `GITHUB_TOKEN`. Sets:
- Description: `🌮 Tiny macOS CLI that keeps your Mac awake while AI coding agents cook.`
- Homepage: `https://github.com/tokenwaster76/laptop_taco`
- Topics: `macos cli bash caffeinate ai developer-tools productivity claude-code codex coding-agents`

You can also set these manually via the gear icon next to "About" on the repo page — takes 30 seconds.

### 2. Social preview image

The SVG source is at `marketing/assets/social-preview.svg`. GitHub requires PNG/JPG, ≤1MB.

```bash
# easiest if you have librsvg installed
rsvg-convert -w 1280 -h 640 marketing/assets/social-preview.svg \
  -o /tmp/social-preview.png
```

Then *Repo Settings → Social preview → Edit → upload `/tmp/social-preview.png`*.

If you don't have `rsvg-convert`, any online SVG→PNG converter works (or open in Figma / Inkscape / a browser screenshot).

### 3. First release + the full launch fan-out

Create `v0.1.0`:
- Either: *Releases → Draft a new release → tag `v0.1.0` → body from `marketing/posts/github-release.md`*
- Or: `marketing/scripts/create-github-release.sh` (needs `GITHUB_TOKEN`)

Publishing the release fires `.github/workflows/auto-announce.yml` which, for every channel whose secret is set in *Settings → Secrets and variables → Actions*:
- Posts to Mastodon, Bluesky, LinkedIn, Threads, Discord, Slack
- Posts to X (only if you set the paid Basic-tier creds)
- Creates DEV.to and Hashnode drafts (you publish manually)
- Posts to Reddit (only if `vars.REDDIT_AUTO_POST_OPT_IN == 'true'` AND a single sub is configured)
- Archives the URL on Wayback
- Syncs description + topics

Missing secrets skip cleanly — partial config is fine.

### 4. Manual submit forms (no public API)

Run `marketing/scripts/open-submit-tabs.sh` on macOS. Opens 4 pre-filled submit forms:
- Hacker News (paste your first comment within 60 seconds)
- Lobsters
- Product Hunt
- Indie Hackers

Plus 5 share-intent fallbacks (X, Bluesky, LinkedIn, Threads, Mastodon) for channels whose API you skipped.

## C. Pre-public sanity checks (already done, but verify)

| Check | Status | Verify |
| --- | --- | --- |
| `bash -n` clean on `taco` | ✅ | `bash -n taco` |
| `bash -n` clean on all 17 marketing scripts | ✅ | `for f in marketing/scripts/*.sh; do bash -n "$f"; done` |
| All 3 workflow YAMLs parse | ✅ | `python3 -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/macos-smoke-test.yml','.github/workflows/marketing-pack.yml','.github/workflows/auto-announce.yml']]"` |
| Every API poster fails-cleanly with no env | ✅ | `marketing/scripts/post-bluesky.sh` (etc.) |
| `generate-launch-pack.sh` produces a non-empty dist | ✅ | `marketing/scripts/generate-launch-pack.sh && wc -l marketing/dist/launch-pack.md` |
| Authorship audit passes (clean tree) | ✅ | run `marketing/scripts/audit-tree.sh` if you want to re-verify |
| `macos-smoke-test` workflow green | ⏳ | https://github.com/tokenwaster76/laptop_taco/actions — check before flipping public |
| Repo is public | ⏳ | step A.2 above |
| Description + topics set | ⏳ | step B.1 |
| Social preview uploaded | ⏳ | step B.2 |
| Release v0.1.0 published | ⏳ | step B.3 |

## D. Known limitations (worth disclosing on launch)

These are honest things to mention if asked:

- **No real screenshot.** The "demo" image in the README is a hand-crafted SVG that looks like a Terminal window with the actual output. It's not a photo of a real session. A real PNG/GIF requires recording on a Mac; you don't currently have one.
- **Closed-lid behavior.** `caffeinate -dim` does NOT override Apple's lid-close sleep. The README and `What this is not` section say so plainly. Don't oversell on launch.
- **Signal propagation to grandchildren.** When you Ctrl+C, taco sends SIGTERM to the immediate `bash -lc` subshell. Most well-behaved agents (Claude Code, Codex, OpenCode) handle SIGTERM and shut their own subprocesses down. A misbehaving command could orphan grandchildren. Acceptable for v0.1.0.
- **CI tests `--help`, `--version`, happy path, exit-code propagation.** It does NOT test the Ctrl+C trap (no reliable TTY harness in v0.1.0) — that's the one path with a "manual verify" checkbox in the PR.

## E. Does the app actually work without a Mac?

You can't run `./taco claude` here. The only honest test of the real script is the `macos-latest` GitHub Actions runner, which spins up a fresh macOS image and:
1. Confirms `caffeinate`, `pmset`, `osascript` exist
2. Syntax-checks `taco`
3. Runs `./taco --help` and `./taco --version`
4. Runs `./taco "echo cooking && sleep 1 && echo done"` (full happy path)
5. Asserts `./taco "exit 42"` exits 42

If that workflow is green, the script works on a real Mac — same OS image Apple ships. The signal-handling path is the only thing not automatically tested; it's covered by manual checkbox.
