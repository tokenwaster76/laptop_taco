# Laptop Taco 🌮

![macOS smoke test](https://github.com/tokenwaster76/laptop_taco/actions/workflows/macos-smoke-test.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![macOS only](https://img.shields.io/badge/macOS-only-black?logo=apple)
![No cloud](https://img.shields.io/badge/cloud-no-brightgreen)
![Made for AI agents](https://img.shields.io/badge/made%20for-AI%20agents-purple)

<!-- Username is already filled in (tokenwaster76 / laptop_taco). If you fork, replace it. -->

> For when Claude is cooking and you need to catch a bus.

AI coding agents can take 10, 20, 30 minutes to refactor, test, and argue with your repo. Your Mac, unfortunately, still believes in sleep. So people started carrying half-open laptops around like tiny aluminum tacos.

This is stupid.

Laptop Taco is a tiny CLI that keeps your Mac awake while your agent command runs, then tells you when it is done.

---

## Why?

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
./taco "echo cooking && sleep 3 && echo done"
```

Anything you pass gets handed to `bash -lc`, so pipes, `&&`, env vars, and aliases work the way you expect.

Exit code is whatever your command returned. `taco "exit 42"` exits 42.

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

## What it does

- Wraps your command
- Starts `caffeinate -dim` so display, idle, and disk stay awake
- Prints PID, start time, battery
- Warns if battery is below 20%
- Sends a macOS notification when it finishes
- Exits with the same code as the wrapped command
- Handles Ctrl+C by terminating the child and cleaning up caffeinate

## What this is not

- Not a GUI app
- Not a cloud service
- Not a replacement for tmux or remote dev boxes
- Not guaranteed closed-lid support (caffeinate cannot promise this)
- Not a serious power-management product
- Not responsible for you cooking your laptop in a backpack

## macOS-only note

Laptop Taco is intentionally macOS-only because it shells out to Apple's built-in `caffeinate`. No Linux. No Windows. No fake portability. If `uname` is not Darwin, taco refuses to fold.

## Safety note

- Do not put a running hot laptop in a backpack.
- Do not block the vents.
- Do not trust a taco with production deploys.

The `-dim` flags keep display, idle timer, and disk awake. They do **not** override Apple's lid-close sleep behavior. If you close the lid, your Mac is probably going to sleep no matter what taco says.

## GitHub Actions macOS test

This repo ships a real macOS smoke test that runs on every push and PR:

- Boots a `macos-latest` runner
- Confirms `caffeinate`, `pmset`, `osascript` exist
- Syntax-checks the script with `bash -n`
- Runs `--help`, `--version`, a happy path, and an exit-code propagation test (`taco "exit 42"` must exit 42)

See [.github/workflows/macos-smoke-test.yml](.github/workflows/macos-smoke-test.yml).

## Roadmap

- `taco doctor`
- `taco status`
- `taco tmux claude`
- Homebrew formula
- Slack / Telegram notification
- Better agent detection
- Optional sound effects
- Taco ASCII art quality improvements
- Panic mode for when the agent starts editing auth files

## Contributing

Make it funny, keep it tiny. If your PR requires a database, Kubernetes, or a pitch deck, it is not a taco.

PRs welcome on bug fixes, copy polish, and small features. Please do not turn this into a framework.

## License

MIT. See [LICENSE](LICENSE).
