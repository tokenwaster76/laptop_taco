# Laptop Taco Launch Kit

Everything needed to ship and share Laptop Taco without typing the same blurb fifteen times. Most channels are fully automated; the four with no public submission API (HN, Lobsters, Product Hunt, Indie Hackers) get pre-filled submit forms so it's two clicks instead of fifty.

> **Principle: automate preparation and as much posting as platforms allow. Skip nothing for "neatness" but never anything that gets accounts banned.**
> The four ban-prone surfaces (HN, Reddit-multi, Lobsters, Product Hunt) are auto-prepared (forms pre-filled) but not auto-submitted. Everything else (LinkedIn, X, Threads, Mastodon, Bluesky, DEV.to, Hashnode, Discord, Slack, GitHub release, Wayback, Reddit single-sub) fires from one button.

## Folder map

```
marketing/
├── README.md                          # this file
├── launch-config.example.env          # template; copy to launch-config.env
├── launch-checklist.md                # pre/launch/post checklist
├── target-communities.md              # per-channel posting plan
├── postmortem-template.md             # fill in 48h after launch
├── posts/                             # one draft per channel
│   ├── x-thread.md
│   ├── linkedin.md
│   ├── bluesky.md
│   ├── mastodon.md
│   ├── threads.md
│   ├── hacker-news.md
│   ├── reddit.md
│   ├── product-hunt.md
│   ├── devto-article.md
│   ├── lobsters.md
│   ├── discord.md
│   ├── slack.md
│   └── github-release.md
├── scripts/
│   ├── generate-launch-pack.sh        # concatenate everything for one-tab launch
│   ├── make-utm-links.sh
│   ├── open-submit-tabs.sh            # 4 no-API submit forms + 5 share-intent fallbacks
│   ├── create-devto-draft.sh
│   ├── create-hashnode-draft.sh
│   ├── post-mastodon.sh
│   ├── post-bluesky.sh
│   ├── post-linkedin.sh
│   ├── post-threads.sh
│   ├── post-x.sh                      # requires paid Basic tier
│   ├── post-reddit.sh                 # opt-in-gated, single sub per call
│   ├── post-discord.sh
│   ├── post-slack.sh
│   ├── create-github-release.sh
│   ├── set-repo-metadata.sh
│   ├── archive-wayback.sh
│   └── get-linkedin-token.sh          # one-time OAuth helper
└── assets/
    ├── social-preview.svg
    └── terminal-demo.txt
```

## Per-channel posting truth table

| Channel | Mode | Script | Risk |
| --- | --- | --- | --- |
| Hacker News submit | ❌ No public API | `open-submit-tabs.sh` opens pre-filled form | Medium — bans for vote solicitation |
| Lobsters submit | ❌ No public API | same | Medium — invite community |
| Product Hunt | ❌ No public API | same | Low ban, high prep cost |
| Indie Hackers | ❌ No public API | same | Low |
| Reddit single-sub | ✅ API, hard-gated | `post-reddit.sh` (needs `REDDIT_AUTO_POST_OPT_IN=true`) | High — strict anti-spam |
| X / Twitter | ✅ API, paid | `post-x.sh` ($100/mo Basic tier) | Low ban risk, real cost |
| LinkedIn | ✅ API, one-time OAuth | `post-linkedin.sh` (after `get-linkedin-token.sh`) | Low |
| Threads (Meta) | ✅ API | `post-threads.sh` | Low |
| Mastodon | ✅ API | `post-mastodon.sh` | Very low |
| Bluesky | ✅ API | `post-bluesky.sh` | Very low |
| DEV.to | ✅ API draft | `create-devto-draft.sh` | None (draft) |
| Hashnode | ✅ API draft | `create-hashnode-draft.sh` | None (draft) |
| Discord | ✅ Webhook | `post-discord.sh` | None (your server) |
| Slack | ✅ Webhook | `post-slack.sh` | None (your workspace) |
| GitHub release | ✅ API | `create-github-release.sh` | None — fires auto-announce |
| Repo metadata | ✅ API | `set-repo-metadata.sh` | None |
| Wayback archive | ✅ Public endpoint | `archive-wayback.sh` | None |

## Fill in `launch-config.env`

```bash
cp marketing/launch-config.example.env marketing/launch-config.env
# edit; leave any service you don't use blank
```

`marketing/launch-config.env` is gitignored. For GitHub Actions, mirror the same values into *Settings → Secrets and variables → Actions*.

## Generate the launch pack

```bash
chmod +x marketing/scripts/*.sh
marketing/scripts/generate-launch-pack.sh
```

Writes `marketing/dist/launch-pack.md` — one big file with the core copy, UTM links, every post draft, and the checklist, with `<REPO_URL>` substituted. That's your launch-day "open in one tab, copy from the top" reference.

## The "one button" launch

Once the repo is public and your secrets are set in GitHub Actions:

1. Run `marketing/scripts/create-github-release.sh` (or click "Publish release" in the GitHub web UI).
2. The `auto-announce.yml` workflow fires on `release.published` and runs every API-safe poster whose secret is set. Missing secrets skip cleanly.
3. On your laptop, run `marketing/scripts/open-submit-tabs.sh`. Nine tabs open: the four no-API submit forms (HN / Lobsters / Product Hunt / Indie Hackers), five share-intent fallbacks (X / Bluesky / LinkedIn / Threads / Mastodon — for whichever API posters you skipped), and the repo itself.
4. Submit HN within the same minute. Paste your first comment within the next 60 seconds. Sit at the keyboard for 2 hours of replies.

## One-time setup helpers

- **LinkedIn token capture:** `marketing/scripts/get-linkedin-token.sh` — opens a browser-paste flow to swap an auth `code` for an access token + author URN. Tokens are ~60 days.
- **Reddit OAuth:** create a "script" app at https://www.reddit.com/prefs/apps and use its client ID/secret with your account password. The script will not run without `REDDIT_AUTO_POST_OPT_IN=true`.
- **X Basic tier:** subscribe at https://developer.x.com/en/portal/products. Required for any posting beyond the rate-limited Free tier.

## Convert the social preview to PNG

GitHub's social preview only accepts PNG / JPG / GIF up to 1 MB.

```bash
# Option A: librsvg
rsvg-convert -w 1280 -h 640 marketing/assets/social-preview.svg \
  -o marketing/assets/social-preview.png

# Option B: Inkscape (CLI)
inkscape marketing/assets/social-preview.svg \
  --export-type=png --export-filename=marketing/assets/social-preview.png \
  -w 1280 -h 640

# Option C: open the SVG in any vector editor / online converter
```

Upload at *Repo Settings → Social preview → Edit*. Do not commit the PNG.

## Test plan before launch day

- `marketing/scripts/generate-launch-pack.sh` writes a non-empty `dist/launch-pack.md`
- `marketing/scripts/make-utm-links.sh` prints 8 channels with the real `REPO_URL`
- Every `post-*` and `create-*` script with no env vars exits 1 and prints an exact `export FOO=...` block — no network calls
- `marketing/scripts/open-submit-tabs.sh` on macOS opens 9 tabs; on Linux prints them
- Manual workflow run from the Actions tab → `Marketing pack` → "Run workflow" → produces a `launch-pack` artifact

## Anti-spam guardrails (built in)

- Every API script posts **once**. No loops, no retries on success, no cross-posting helpers.
- DEV.to and Hashnode are hard-coded to draft. Human still hits Publish.
- Webhooks address only the URLs you paste — by construction they can't go anywhere else.
- `auto-announce.yml` only fires on `release.published` or manual dispatch. No cron.
- `post-reddit.sh` refuses to post twice in 60 seconds, refuses without `REDDIT_AUTO_POST_OPT_IN=true`, refuses if `REDDIT_SUBREDDIT` contains commas or `+`.
- No content is generated dynamically. Every post is a static file you can review and edit.

## What this kit deliberately does NOT do

- Solicit upvotes, follows, or claps anywhere.
- DM strangers.
- Submit to multiple Reddit subs from one invocation.
- Fan out the same Mastodon post to several instances.
- Auto-reply to any comment, ever.
- Auto-publish the DEV.to / Hashnode drafts.
- Run on a cron.
