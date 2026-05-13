# Reddit drafts

> **Reddit is the platform most likely to shadow-ban you for self-promo.** `post-reddit.sh` exists, but it only fires when `REDDIT_AUTO_POST_OPT_IN=true` AND `REDDIT_SUBREDDIT` is set to a single sub. It will not cross-post. It will not retry. It will refuse to run twice in the same minute. Read each sub's rules first — most enforce a 10:1 comment-to-self-promo ratio, some ban all link posts, some require flair, some want a self-text post instead of a link.

Three versions tuned to three audiences. Pick one sub at a time. Do not mass-post.

---

## r/SideProject — gonzo, meme-friendly, indie-builder

**Title:** I built a tiny macOS CLI so I could stop carrying my laptop around like an aluminum taco

**Body:**

It is 2026. AI coding agents now run for 10, 20, sometimes 30 minutes per task. Mac wants to sleep. You want to leave the house. Result: developers across the world are walking around clutching half-open MacBooks like little aluminum tacos, hoping the agent doesn't die mid-refactor.

I refused to participate in this lid-ajar nightmare.

**Laptop Taco 🌮** is one Bash script. macOS-only. Zero dependencies. It wraps your command with `caffeinate`, prints PID, battery, runtime, warns you if the battery is low, sends a native macOS notification when the agent is done, and exits with the same code as your command.

```
./taco claude
./taco codex
./taco "npm test"
```

No app. No account. No cloud. No subscription. No newsletter. No roadmap to a Series A. Just a responsible taco.

GitHub: <REPO_URL>

Open to feedback on the script, the safety warnings, or what other AI-agent quality-of-life things should exist.

---

## r/programming — neutral, technical

**Title:** Laptop Taco: a small Bash wrapper around macOS `caffeinate` for long-running CLI commands

**Body:**

Small open-source utility. It is a single Bash script that wraps an arbitrary command with `caffeinate -dim -w <pid>`, captures the child PID, traps `SIGINT`/`SIGTERM` for clean shutdown, parses `pmset -g batt` for a battery readout, emits a macOS notification on completion, and propagates the wrapped command's exit code precisely.

Motivating use case: long-running CLI agents (coding agents, big test suites, builds, video renders) that you don't want the system to sleep through.

Design notes:

- macOS-only on purpose — `caffeinate` is the dependency; there is no fallback for Linux/Windows because the abstraction would be dishonest.
- Flag handling (`--help`, `--version`) runs before the Darwin guard, so the script lints and reports its version on any platform.
- No `set -e`; uses `set -u` and `pipefail` and explicit exit-code capture from `wait` because precise exit-code propagation is the whole point.
- Runs the command via `/bin/bash -lc` so pipes, `&&`, env vars, and aliases work.
- Hours-aware runtime formatter (`2h 7m 5s`) because the killer use case is multi-hour AI agent runs.

A `macos-latest` GitHub Actions workflow smoke-tests the script on every push: tool availability, syntax, `--help`, `--version`, happy path, and `taco "exit 42"` exit-code propagation.

Source: <REPO_URL>

Happy to take critique on the trap handling and exit-code propagation in particular.

---

## r/macapps — macOS user audience

**Title:** Laptop Taco: a tiny CLI that keeps your Mac awake while a command runs, then notifies you when it's done

**Body:**

If you ever start a long terminal task and then have to step away from your desk — `npm test`, a 30-minute video render, an AI coding agent doing a multi-file refactor — your Mac is probably going to sleep before the task finishes. The usual workarounds are awkward: open Activity Monitor and pretend, leave the lid half-open, or install a menu-bar app you'll forget about.

`Laptop Taco` is a tiny CLI that fixes that:

```
./taco "any-long-command"
```

It wraps the command with Apple's built-in `caffeinate -dim` so display, idle, and disk stay awake, prints PID and battery, warns if the battery drops below 20%, sends a native macOS notification when the command finishes, and exits with the same code as the wrapped command.

No GUI, no menu-bar app, no login items, no account, no telemetry, no auto-updater. One Bash script, MIT licensed, macOS-only.

GitHub: <REPO_URL>

Note: this does NOT override the closed-lid sleep behavior. If you close the lid, your Mac is going to sleep regardless. Don't put a hot running laptop in your backpack.
