# LinkedIn post

Post via `post-linkedin.sh` after one-time OAuth setup, or by API on `release.published`. Image: `marketing/assets/social-preview.png` (convert the SVG before posting).

---

Industry observation from 2026: AI coding agents have invented a new developer ritual.

It is called The Half-Open Laptop Walk.

You have probably seen it. A developer striding through the coffee shop with a MacBook tucked under their arm, lid wedged maybe halfway open. Not closed. Not open. Half. Like an aluminum taco. They are not making a fashion statement. They are simply trying to keep an AI coding agent alive while they catch a bus.

Modern agents — Claude Code, Codex, OpenCode, Gemini CLI, Cursor agents — can run for 10, 20, sometimes 30 minutes per task. Closing the lid suspends the process. Walking away triggers sleep. So people are doing the only thing they can think of: stop the lid from closing, ignore the thermal warnings, and hope nothing melts.

The fix has been built into macOS for over a decade.

It is called `caffeinate`. It is one command.

So I wrote 150 lines of Bash that automate the obvious thing. It is called **Laptop Taco 🌮** and it does exactly one job: wrap your long-running command, keep the Mac awake, print PID and battery, warn you on low charge, and send a notification when the agent is done. Same exit code as your command. No GUI. No account. No cloud. No subscription. No newsletter. Just a responsible taco.

The repo and a `macos-latest` GitHub Actions smoke test: <REPO_URL>

If you are also tired of carrying small aluminum tacos around, this is for you.

#AI #DeveloperTools #macOS #OpenSource #IndieDev
