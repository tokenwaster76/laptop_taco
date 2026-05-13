# Launch checklist

The shape of this checklist is intentional: the boring stuff is automated, the unautomatable stuff is grouped and labelled so you can't forget it.

## Before launch

### Repo readiness

- [ ] **Repo is public.** Flip via *Settings → Danger Zone → Change repository visibility*. Nothing else in this kit works against a private repo.
- [ ] GitHub Actions are green on `main`
- [ ] README looks right at desktop + mobile widths (the badges row wraps cleanly)
- [ ] Demo block in README matches actual `./taco` output
- [ ] LICENSE and `.gitignore` are present
- [ ] `marketing/assets/social-preview.svg` has been converted to PNG and uploaded via *Settings → Social preview*
- [ ] Repo description + topics are set (run `marketing/scripts/set-repo-metadata.sh` once)

### Credentials staged

Set as repository secrets in *Settings → Secrets and variables → Actions* (also locally in `marketing/launch-config.env`). Each is optional — leaving one blank just skips that channel.

- [ ] `DEVTO_API_KEY` — DEV.to draft
- [ ] `HASHNODE_API_TOKEN` + `HASHNODE_PUBLICATION_ID` — Hashnode draft
- [ ] `MASTODON_INSTANCE` + `MASTODON_ACCESS_TOKEN`
- [ ] `BLUESKY_HANDLE` + `BLUESKY_APP_PASSWORD`
- [ ] `LINKEDIN_ACCESS_TOKEN` + `LINKEDIN_AUTHOR_URN` (run `get-linkedin-token.sh` once)
- [ ] `THREADS_ACCESS_TOKEN` + `THREADS_USER_ID`
- [ ] `X_API_KEY` + `X_API_SECRET` + `X_ACCESS_TOKEN` + `X_ACCESS_TOKEN_SECRET` (paid tier; skip if you'd rather use the tweet-intent URL)
- [ ] `DISCORD_WEBHOOK_URL` for your own server
- [ ] `SLACK_WEBHOOK_URL` for your own workspace
- [ ] `GITHUB_TOKEN` (fine-grained PAT) for release + metadata sync

### Drafts reviewed

- [ ] Skim every file in `marketing/posts/`. Replace `<REPO_URL>` mentally with the real URL; the scripts substitute at post time.
- [ ] HN first comment is in your clipboard / a pinned tab — it has to go up within 60 seconds of submission.
- [ ] You have 2 free hours after the HN submit timestamp to reply to comments.

## Launch day

### Auto-fire

1. **Run `marketing/scripts/set-repo-metadata.sh`** to confirm description + topics + homepage.
2. **Run `marketing/scripts/create-github-release.sh`** (or click "Publish release" in the GitHub UI).
   - This fires `.github/workflows/auto-announce.yml` on `release.published`.
   - Each channel script runs **only if its secret is set**. Missing secrets skip cleanly.
   - Channels handled automatically: Mastodon, Bluesky, DEV.to draft, Hashnode draft, LinkedIn, Threads, X (if paid creds present), Discord, Slack, Wayback archive, repo description/topics sync.
3. **Open `marketing/scripts/open-submit-tabs.sh`** (on macOS). Four tabs open with pre-filled forms:
   - Hacker News (paste your first-comment draft as soon as the post lands)
   - Lobsters
   - Product Hunt (only if you're prepared for a launch-day day; otherwise close it)
   - Indie Hackers
   - Plus 5 share-intent fallback tabs (in case you skipped any API channel above).

### Manual surgery

These take real human cycles. Block 2 hours.

- [ ] Submit Show HN. Paste the first comment within 60 seconds.
- [ ] Reply to every HN comment for the first 2 hours. Take feedback at face value; don't argue.
- [ ] Submit to Lobsters only if you have an account in good standing and the topic genuinely fits.
- [ ] If posting on Reddit, choose **one** sub. Read its rules. Use `post-reddit.sh` with `REDDIT_AUTO_POST_OPT_IN=true` and `REDDIT_SUBREDDIT=<one-sub>`. Do not cross-post.
- [ ] If Product Hunt: launch around 12:01 AM Pacific, paste the maker comment within 60 seconds, be on-call for replies all day.

## After launch (first 48 hours)

- [ ] Star, fork, issue counts captured for the postmortem
- [ ] Best public comments collected (one screenshot per platform)
- [ ] First 1–2 small fixes shipped from launch-day feedback
- [ ] Any obvious bugs from "smart strangers tested it" filed as issues
- [ ] "Launch notes" issue opened with the rough numbers
- [ ] DEV.to draft + Hashnode draft published (manually — they were drafts on purpose)
- [ ] Postmortem written in `marketing/postmortem-<DATE>.md` using `postmortem-template.md`

## Things to never do

- Solicit upvotes on HN, Lobsters, Reddit, Product Hunt. This is the fastest known way to a shadow-ban.
- Cross-post the same Reddit submission to more than one sub. The site flags this within minutes.
- Buy followers / stars / claps. Visible, traceable, embarrassing.
- Auto-DM strangers about the launch. There is no faster way to be muted by everyone whose opinion you wanted.
- Run `post-reddit.sh` in a loop. The script literally refuses.
