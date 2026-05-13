# Why this folder is public, and is any of it against ToS?

Two real questions. Two real answers.

## 1. Should `marketing/` be public or private?

**Recommendation: keep it public.**

Reasons:

- The whole project vibe is meta and self-aware. Shipping the marketing kit alongside the meme-tool is part of the joke. Indie Hackers and r/SideProject reward this.
- The audit script (`marketing/scripts/audit-tree.sh`) is itself a feature: it proves you keep the project's authorship clean. Hiding the audit makes that signal smaller.
- The launch playbook is shareable on its own merit — "here is the gonzo X thread I will use, here is the deadpan HN post, here are the API scripts" is real content.
- Removing it would itself be more work than keeping it (rewriting README links, splitting the repo, maintaining two trees).

Counter-arguments — and why they don't quite win:

- *"Eagle-eyed readers will see the exact text in `posts/x-thread.md` and call you astroturfy."* The text is your own. You wrote it. The repo's commit history shows you, not a botnet. Drafting a launch post is not astroturfing.
- *"It reveals which channels you have credentials for."* No, it reveals which channels the *kit supports*. Whether you have the creds set is invisible — secrets are repo secrets, not in the tree.
- *"It looks try-hard."* Maybe to one in twenty viewers. The other nineteen read it as competent.

If you change your mind later: `git mv marketing /path/to/private-repo/` is one command. The kit is portable.

What stays gitignored regardless (already configured):

- `marketing/dist/` — generated launch-pack artifacts
- `marketing/launch-config.env` — real credentials, if you ever fill one in
- `marketing/assets/social-preview.png` — local conversions of the SVG

## 2. Is any of the committed material against platform ToS?

Audited per-platform. **Short answer: no.** Long answer below — read the caveats.

| Platform | What we do | ToS verdict | Why |
| --- | --- | --- | --- |
| **X / Twitter** | One thread per launch via API v2 with user OAuth | ✅ Allowed | Posting on behalf of your own account is the documented use case for Basic tier. We don't loop, don't schedule, don't auto-follow. |
| **LinkedIn** | One UGC post per launch with `w_member_social` | ✅ Allowed | Standard self-share scope. |
| **Mastodon** | One status per launch | ✅ Allowed | The API is built for clients. Caveat: some smaller instances have rules against "API-only" accounts — check your home instance rules. Mastodon.social is fine. |
| **Bluesky** | One post via ATProto with app password | ✅ Allowed | App passwords exist specifically for this. |
| **Threads (Meta)** | One post via the official Threads API | ✅ Allowed | Official client API, two-step create-then-publish. |
| **DEV.to** | API draft (`published: false`) | ✅ Allowed | Documented endpoint. We never auto-publish. |
| **Hashnode** | API draft | ✅ Allowed | Same. |
| **Discord webhook** | POST to a URL you own | ✅ Allowed | Webhooks are the intended pattern. |
| **Slack webhook** | POST to a URL you own | ✅ Allowed | Same. |
| **GitHub release** | API release on your own repo | ✅ Allowed | Standard. |
| **GitHub repo metadata** | PATCH description/topics on your own repo | ✅ Allowed | Standard. |
| **Wayback Machine** | One `web.archive.org/save/<url>` call | ✅ Allowed | Public Save Page Now endpoint. |
| **Reddit** | Single sub per call, opt-in gated, 60s rate limit | ⚠️ See caveat | API itself is allowed; spam filter is the risk (see below). |
| **Hacker News / Lobsters / Product Hunt / Indie Hackers** | We only open pre-filled submit URLs | ✅ Allowed | A pre-filled hyperlink is not automation. The human clicks Submit. |

### Where the real ToS-adjacent risks are (not the code, the use)

These are usage-pattern risks. The kit's guardrails actively reduce them, but they cannot fully prevent them:

1. **Reddit shadowbans on new / low-karma accounts.** Reddit's spam ML filters first-time self-promo from accounts without karma, comment history, or sub participation — regardless of whether you posted manually or via API. The kit cannot fix this; only your account history can. If `tokenwaster76` is brand new on Reddit, post manually after participating in the target sub for a couple weeks first. The opt-in gate on `post-reddit.sh` exists for exactly this reason.
2. **Vote manipulation on HN.** If you ask friends to upvote your Show HN, that is against HN guidelines. The kit doesn't help with this and shouldn't be read as encouragement to. The first-comment draft is the legitimate version: be present, answer questions, take feedback.
3. **Multi-instance Mastodon cross-posting.** Same post to several instances within minutes will trigger spam heuristics on the larger ones. The kit deliberately only supports one Mastodon instance per launch.
4. **X "coordinated inauthentic behavior".** Don't run `post-x.sh` from multiple accounts to amplify the same launch. Doesn't apply if you're posting solo.

### What is NOT a ToS concern

- The `marketing/` folder being public.
- The post drafts being readable.
- The script files being readable.
- Workflow names mentioning each channel — secrets are stored as GitHub Secrets and never in the tree.
- Anyone forking the repo and using the kit for their own project — it's MIT.

## TL;DR

Keep `marketing/` public, ship the kit as part of the launch story, and run it once per channel per launch. Don't auto-cross-post Reddit. Don't pay-for-upvote anything. You're fine.
