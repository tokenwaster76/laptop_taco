# Target communities

Per-channel posting plan. Risk column is "what gets you banned/shadowbanned" — read it, not just the title.

## Manual submit (no public API)

### Hacker News — Show HN

- **Best angle:** "Tiny meme tool for a real new ritual" — Show HN audience likes small, well-explained, opinionated tools.
- **Risk level:** Medium. Showing up only to drop a link and disappear gets you flagged. Solicting upvotes is an instant ban.
- **Exact title:** `Show HN: Laptop Taco – keep your Mac awake while coding agents run`
- **Manual or auto:** Manual. `open-submit-tabs.sh` opens the submit form pre-filled.
- **Notes:** Post first comment within 60 seconds. Be available for 2 hours of replies. Don't argue with negativity — acknowledge, fix what's fixable.

### Product Hunt

- **Best angle:** "Tiny macOS CLI for long-running AI agents." Maker comment leads with the absurdity.
- **Risk level:** Low for bans, high for wasted effort if launch day isn't prepared.
- **Exact title:** `Laptop Taco 🌮 — Tiny macOS CLI for long-running AI agents`
- **Manual or auto:** Manual. Only launch if you have the day clear, supporters lined up, and assets ready.
- **Notes:** 12:01 AM Pacific or skip. Half-prepared launches die in the first hour.

### Reddit (selectively, one sub per launch)

- **Best angle:** Match the sub. `r/SideProject` likes meme tools; `r/programming` wants technical detail; `r/macapps` wants macOS-user framing.
- **Risk level:** **High.** Reddit's spam filter is extremely aggressive. Cross-posting + automation = shadowban within minutes.
- **Exact title:** see `posts/reddit.md` — three drafts, one per sub.
- **Manual or auto:** `post-reddit.sh` exists but is hard-gated behind `REDDIT_AUTO_POST_OPT_IN=true` AND a single `REDDIT_SUBREDDIT`. Use it for one sub. Read the rules first.
- **Notes:** Comment-to-self-promo ratio above 10:1 is the baseline. New / low-karma accounts will get filtered.

### Lobsters

- **Best angle:** Technical detail. No emojis except maybe the title taco. The audience wants signal.
- **Risk level:** Medium. Invite-only community. Off-topic or salesy posts are downvoted hard.
- **Exact title:** `Laptop Taco: a tiny macOS caffeinate wrapper for long-running coding agents`
- **Manual or auto:** Manual. Tags: `release, unix, mac, show`.
- **Notes:** Only post if you actually have a Lobsters account and have been participating in good faith.

### Indie Hackers

- **Best angle:** Meme tool that ended a workflow papercut. Build-in-public friendly.
- **Risk level:** Low.
- **Exact title:** `I built Laptop Taco — a tiny macOS CLI so I could stop carrying my MacBook around half-open`
- **Manual or auto:** Manual.
- **Notes:** Best follow-up is to journal the launch numbers in a follow-up post a week later.

## API / draft-safe

### DEV.to

- **Best angle:** Longer-form. The article in `posts/devto-article.md` opens gonzo, body sober.
- **Risk level:** Very low. Drafts are private until you Publish.
- **Manual or auto:** `create-devto-draft.sh` (always `published: false`).
- **Notes:** Tag with `ai, cli, macos, opensource`.

### Hashnode

- **Best angle:** Same body as DEV.to.
- **Risk level:** Very low. Same draft-only guarantee.
- **Manual or auto:** `create-hashnode-draft.sh`.
- **Notes:** Needs a publication ID (your blog's), not a user ID.

### Mastodon

- **Best angle:** Casual, ≤500 chars.
- **Risk level:** Very low (your own instance).
- **Manual or auto:** `post-mastodon.sh`.

### Bluesky

- **Best angle:** Casual, ≤300 chars.
- **Risk level:** Very low.
- **Manual or auto:** `post-bluesky.sh`.

### Threads (Meta)

- **Best angle:** Same as Bluesky/Mastodon.
- **Risk level:** Low.
- **Manual or auto:** `post-threads.sh`.

### LinkedIn

- **Best angle:** Professional but tongue-in-cheek. The "Industry observation" framing in `posts/linkedin.md` outperforms plain announcement posts.
- **Risk level:** Low. Personal posts under `w_member_social` scope are fine.
- **Manual or auto:** `post-linkedin.sh` (one-time OAuth via `get-linkedin-token.sh`).

### X / Twitter

- **Best angle:** 5-post thread.
- **Risk level:** Low for bans (your own account), high for cost ($100/mo Basic tier required for write access).
- **Manual or auto:** `post-x.sh` if you've paid. Otherwise `open-submit-tabs.sh` opens a pre-filled tweet-intent URL — two clicks instead of fifty.

## Social / manual

### Discord

- **Best angle:** Your own server. Posting in someone else's server without permission is just spam.
- **Risk level:** Low if it's your channel.
- **Manual or auto:** `post-discord.sh` (webhook).

### Slack

- **Best angle:** Same — your own workspace.
- **Risk level:** Low.
- **Manual or auto:** `post-slack.sh` (incoming webhook).

### Personal communities

- **Best angle:** People you actually know, in whatever Discord/Slack/Telegram channel you already participate in.
- **Risk level:** None if you participate genuinely; very high if you "introduce yourself" by dropping the link cold.
- **Manual or auto:** Manual — by definition.
- **Notes:** Best ROI on the launch by far. One genuine recommendation from someone with audience trust > 100 random tweets.

## Anti-pattern reminders

- **Multi-sub Reddit posting.** Filed under "spam" within minutes.
- **Cross-instance Mastodon posting.** Same. Pick one instance.
- **DMing strangers.** Single-fastest way to be muted forever.
- **Faking momentum.** Bought stars / claps / followers are visible and traceable.
- **Auto-replying to comments.** Every reply has to be a real human.
