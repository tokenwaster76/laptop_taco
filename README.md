<div align="center">

```
   _                 _              _____
  | |               | |            |_   _|
  | |     __ _ _ __ | |_ ___  _ __   | | __ _  ___ ___
  | |    / _` | '_ \| __/ _ \| '_ \  | |/ _` |/ __/ _ \
  | |___| (_| | |_) | || (_) | |_) | | | (_| | (_| (_) |
  \_____/\__,_| .__/ \__\___/| .__/  \_/\__,_|\___\___/
              | |            | |
              |_|            |_|
```

# Laptop Taco 🌮

**For when your agent is cooking and you need to catch a bus.**

[![macOS smoke test](https://github.com/tokenwaster76/laptop_taco/actions/workflows/macos-smoke-test.yml/badge.svg)](https://github.com/tokenwaster76/laptop_taco/actions/workflows/macos-smoke-test.yml)
[![License: MIT](https://img.shields.io/github/license/tokenwaster76/laptop_taco?color=blue)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/tokenwaster76/laptop_taco?include_prereleases&sort=semver&label=release)](https://github.com/tokenwaster76/laptop_taco/releases)
[![GitHub stars](https://img.shields.io/github/stars/tokenwaster76/laptop_taco?style=flat&color=yellow)](https://github.com/tokenwaster76/laptop_taco/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/tokenwaster76/laptop_taco?style=flat&color=lightgray)](https://github.com/tokenwaster76/laptop_taco/network/members)
[![Last commit](https://img.shields.io/github/last-commit/tokenwaster76/laptop_taco?color=informational)](https://github.com/tokenwaster76/laptop_taco/commits)
[![Repo size](https://img.shields.io/github/repo-size/tokenwaster76/laptop_taco)](https://github.com/tokenwaster76/laptop_taco)
[![Code size](https://img.shields.io/github/languages/code-size/tokenwaster76/laptop_taco)](https://github.com/tokenwaster76/laptop_taco)
[![Top language](https://img.shields.io/github/languages/top/tokenwaster76/laptop_taco?color=green)](https://github.com/tokenwaster76/laptop_taco)
[![macOS only](https://img.shields.io/badge/macOS-only-black?logo=apple&logoColor=white)](#macos-only-note)
[![No dependencies](https://img.shields.io/badge/dependencies-zero-success)](#how-it-works)
[![No cloud](https://img.shields.io/badge/cloud-no-brightgreen)](#what-this-is-not)
[![Made for AI agents](https://img.shields.io/badge/made%20for-AI%20agents-purple)](#why)

</div>

---

It is 2026. People are wandering through coffee shops clutching half-open MacBooks at exactly 45° because their AI coding agents refuse to die quietly. The lid stays cracked because closing it kills the process. The fan is screaming. The aluminum is warm enough to brand a steak. The dignity is medium-rare.

I refused to participate in this lid-ajar nightmare.

**Laptop Taco** is one Bash script that wraps your long-running command with macOS `caffeinate`, prints PID + battery + runtime, warns on low battery, and pings you when the agent is done cooking. Same exit code as your command. macOS-only on purpose. ~150 lines. MIT. No app. No account. No cloud. No subscription. No newsletter. No telemetry. No auto-updater.

Just a responsible taco.

## Table of contents

- [Why](#why)
- [Install](#install)
- [Usage](#usage)
- [Demo](#demo)
- [How it works](#how-it-works)
- [Compared to](#compared-to)
- [FAQ](#faq)
- [What this is not](#what-this-is-not)
- [macOS-only note](#macos-only-note)
- [Safety](#safety)
- [GitHub Actions smoke test](#github-actions-smoke-test)
- [Roadmap](#roadmap)
- [Share](#share)
- [Star history](#star-history)
- [Contributing](#contributing)
- [License](#license)

## Why

- Your laptop wants to sleep. Your agent wants to refactor 47 files. Taco mediates.
- Stop walking around like a cyber goblin with a half-open laptop.
- Caffeinate, but make it stupid.
- No app. No account. No cloud. Just a responsible taco.

Built for Claude Code, Codex, OpenCode, Gemini CLI, Cursor agents, and suspiciously long `npm test` runs.

## Install

```bash
git clone https://github.com/tokenwaster76/laptop_taco.git
cd laptop_taco
chmod +x taco
./taco --help
```

Optional, put it on your PATH:

```bash
ln -s "$(pwd)/taco" /usr/local/bin/taco
```

No package manager. No dependencies. It is one Bash file.

## Usage

```bash
./taco claude
./taco codex
./taco opencode
./taco "npm test"
./taco "rake spec"
./taco "echo cooking && sleep 3 && echo done"
```

Anything you pass gets handed to `bash -lc`, so pipes, `&&`, env vars, and aliases work the way you expect.

Exit code is whatever your command returned. `./taco "exit 42"` exits 42.

## Demo

```
🌮 Laptop Taco engaged

Keeping your Mac awake while this runs:

  claude

PID: 42117
Started: 14:32:08
Battery: 74%
Mode: cracked-open chaos

Do not put a hot running laptop in a backpack. Seriously.
Close the taco with Ctrl+C.

[claude] reading 47 files...
[claude] proposing 3 refactors...
[claude] done.

✅ Agent finished cooking
Runtime: 23m 18s
Exit code: 0

You may now close the taco.
```

## How it works

It is deliberately small. The whole pipeline is:

1. **Flag handling first.** `--help` and `--version` are handled before any platform check, so the script lints and reports its version on any OS. Useful for CI and `bash -n`.
2. **Darwin guard.** If `uname` is not `Darwin`, the script exits 1 with a clear message. `caffeinate` is the dependency; there is no honest fallback for Linux or Windows.
3. **Argument capture.** All args are joined into one command string, then handed to `/bin/bash -lc "$command"` so pipes, `&&`, env vars, and aliases all work.
4. **Background launch + caffeinate.** Your command runs in the background; its PID is captured. Then `/usr/bin/caffeinate -dim -w <pid>` starts in the background and exits automatically when the child dies.
5. **Battery readout.** `pmset -g batt` is best-effort. If parseable, the script prints the percentage and warns if it's under 20%. If unparseable (desktop Mac, parser change), the line is omitted silently.
6. **Signal handling.** `trap on_interrupt INT TERM` kills the child cleanly, cleans up `caffeinate`, waits, and exits 130 on Ctrl+C.
7. **Exit-code propagation.** `set -u` + `set -o pipefail`, but no `set -e` — because the whole point is to capture the child's exit code from `wait` and pass it through verbatim.
8. **Notification.** `osascript -e 'display notification ...'` fires on completion. Notification failure never fails the run.
9. **Runtime formatting.** `7s`, `23m 18s`, or `2h 7m 5s`, because the killer use case is multi-hour agent runs and `127m 5s` looks dumb.

That's the whole tool. No daemon. No menu-bar icon. No config file. No state to corrupt.

## Compared to

| | `Laptop Taco` | raw `caffeinate` | Amphetamine | Theine | KeepingYouAwake |
| --- | :---: | :---: | :---: | :---: | :---: |
| One-line install | ✅ | ✅ (built-in) | ❌ (App Store) | ❌ (App Store) | ✅ (Homebrew cask) |
| No GUI / pure CLI | ✅ | ✅ | ❌ | ❌ | ❌ |
| Auto-stops when wrapped process exits | ✅ | ⚠️ (need `-w` + PID) | ⚠️ (timer / trigger) | ⚠️ (timer / trigger) | ⚠️ (timer / trigger) |
| Prints PID + runtime | ✅ | ❌ | ❌ | ❌ | ❌ |
| Battery warning | ✅ | ❌ | ✅ | ❌ | ❌ |
| Native notification on finish | ✅ | ❌ | ✅ | ✅ | ❌ |
| Same exit code as wrapped command | ✅ | ❌ | n/a | n/a | n/a |
| No account / no cloud | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dependencies beyond macOS | 0 | 0 | n/a | n/a | 0 |
| License | MIT | Apple | Proprietary | Proprietary | MIT |

Honest version: raw `caffeinate -w <pid>` does the same thermal/awake job. Laptop Taco is the part above it — the argument parsing, battery readout, signal handling, notification, exit-code propagation, and one-line invocation that doesn't require you to know the PID before the process exists.

## FAQ

**Why macOS only?**
Because `caffeinate` is the whole dependency, and there's no honest equivalent on Linux or Windows that does the same thing the same way. `systemd-inhibit`, `xset s off`, and `caffeine` all behave differently. Pretending one wrapper handles all three would be dishonest portability.

**Why Bash, not Go / Rust / Python?**
Half the value is that you can read all of it in one sitting. ~150 lines of Bash that you can audit before you `chmod +x` is a feature, not a limitation.

**Does it work with the lid closed?**
No. Apple's lid-close sleep is its own beast and `caffeinate -dim` does not override it. If you close the lid, the Mac is going to sleep regardless. Do not put a hot laptop in a backpack.

**What happens if my agent runs out of battery?**
`caffeinate` keeps the OS awake, not the laws of physics. When the battery hits 0%, your Mac shuts down. The script warns you at 20%. Plug in.

**Why no config file?**
Because there is nothing to configure. The job is "keep the system awake until this command exits, then say so." Adding flags would make the help text longer than the implementation.

**Will you add Homebrew?**
On the roadmap. The friction is owning the tap, not the formula.

**Can I use this with `tmux`?**
Yes. Wrap your tmux command: `./taco "tmux new -s long-job 'rake spec'"`. Or just run `./taco` inside a tmux pane.

**Will it work with `claude` / `codex` / `opencode` / Cursor agents?**
Yes — any command, any agent. The script doesn't know or care what's inside. `./taco <whatever-you-type>`.

**Does it slow down my Mac?**
No. `caffeinate` does not consume CPU. The Bash wrapper does one `wait` and goes to sleep.

**Will my Mac overheat?**
`caffeinate -dim` only inhibits idle, display, and disk sleep. It does not override thermal management. Apple's thermal throttling still works. That said: read the safety section.

## What this is not

- Not a GUI app
- Not a cloud service
- Not a replacement for `tmux` or a remote dev box
- Not guaranteed closed-lid support
- Not a serious power-management product
- Not responsible for you cooking your laptop in a backpack
- Not a subscription
- Not a startup

## macOS-only note

Laptop Taco is intentionally macOS-only because it shells out to Apple's built-in `caffeinate`. No Linux. No Windows. No fake portability. If `uname` is not `Darwin`, taco refuses to fold.

## Safety

- Do not put a running hot laptop in a backpack.
- Do not block the vents.
- Do not trust a taco with production deploys.

The `-dim` flags keep display, idle timer, and disk awake. They do **not** override Apple's lid-close sleep behavior. If you close the lid, your Mac is probably going to sleep no matter what taco says.

## GitHub Actions smoke test

This repo ships a real `macos-latest` smoke test that runs on every push and pull request:

- Boots a `macos-latest` runner
- Confirms `caffeinate`, `pmset`, `osascript` exist on the runner
- Syntax-checks the script with `bash -n`
- Runs `./taco --help`, `./taco --version`, and a happy-path command
- Asserts that `./taco "exit 42"` exits with code 42

See [.github/workflows/macos-smoke-test.yml](.github/workflows/macos-smoke-test.yml).

## Roadmap

- `taco doctor` — diagnose `caffeinate`, `pmset`, `osascript`, notification permission
- `taco status` — show whether a previous taco is still running
- `taco tmux <command>` — wrap inside a detached tmux session
- Homebrew tap + formula
- Slack / Telegram notification (in addition to the macOS one)
- Better agent auto-detection (set `Mode:` line from the bin name)
- Optional sound effects (a tiny `say done` is tempting)
- Taco ASCII art quality improvements
- Panic mode for when the agent starts editing auth files

## Share

If this made you laugh or saved your agent run, throw it at someone whose hinge you might be saving:

```text
People are walking around with half-open laptops so AI coding agents do not fall asleep mid-task.

So I made Laptop Taco 🌮

No app. No account. No cloud. Just a responsible taco.

https://github.com/tokenwaster76/laptop_taco
```

One-click compose (pre-fills the text):

- [Share on X / Twitter](https://twitter.com/intent/tweet?text=People%20are%20walking%20around%20with%20half-open%20laptops%20so%20AI%20coding%20agents%20don%27t%20fall%20asleep%20mid-task.%20So%20I%20made%20Laptop%20Taco%20%F0%9F%8C%AE%20%E2%80%94%20a%20tiny%20macOS%20CLI%20for%20long-running%20agents.%20https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco)
- [Share on Bluesky](https://bsky.app/intent/compose?text=People%20are%20walking%20around%20with%20half-open%20laptops%20so%20AI%20coding%20agents%20don%27t%20fall%20asleep%20mid-task.%20So%20I%20made%20Laptop%20Taco%20%F0%9F%8C%AE%20%E2%80%94%20a%20tiny%20macOS%20CLI.%20https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco)
- [Share on LinkedIn](https://www.linkedin.com/sharing/share-offsite/?url=https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco)
- [Share on Threads](https://threads.net/intent/post?text=People%20are%20walking%20around%20with%20half-open%20laptops%20so%20AI%20coding%20agents%20don%27t%20fall%20asleep%20mid-task.%20So%20I%20made%20Laptop%20Taco%20%F0%9F%8C%AE.%20https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco)
- [Share on Mastodon (via toot.kytta.dev)](https://toot.kytta.dev/?text=People%20are%20walking%20around%20with%20half-open%20laptops%20so%20AI%20coding%20agents%20don%27t%20fall%20asleep%20mid-task.%20So%20I%20made%20Laptop%20Taco%20%F0%9F%8C%AE%20%E2%80%94%20a%20tiny%20macOS%20CLI.%20https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco)
- [Submit to Hacker News](https://news.ycombinator.com/submitlink?u=https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco&t=Show%20HN%3A%20Laptop%20Taco%20%E2%80%93%20keep%20your%20Mac%20awake%20while%20coding%20agents%20run)
- [Submit to Lobsters](https://lobste.rs/stories/new?title=Laptop%20Taco%3A%20a%20tiny%20macOS%20caffeinate%20wrapper%20for%20long-running%20coding%20agents&url=https%3A%2F%2Fgithub.com%2Ftokenwaster76%2Flaptop_taco&tags=release%2Cunix%2Cmac%2Cshow)

Social preview image: see [`marketing/assets/social-preview.svg`](marketing/assets/social-preview.svg). Convert to PNG before uploading via *Repo Settings → Social preview*.

Full launch kit (post drafts, API posters, automation workflows): [`marketing/`](marketing/).

## Star history

[![Star history](https://api.star-history.com/svg?repos=tokenwaster76/laptop_taco&type=Date)](https://star-history.com/#tokenwaster76/laptop_taco&Date)

## Contributing

Make it funny, keep it tiny. If your PR requires a database, Kubernetes, or a pitch deck, it is not a taco.

PRs welcome on bug fixes, copy polish, and small features. Please do not turn this into a framework.

## License

MIT. See [LICENSE](LICENSE).
