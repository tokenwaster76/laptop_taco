# 🌮 Laptop Taco v0.1.0 — Pre-Cyborg Era

For when your agent is cooking and you need to catch a bus.

## What is this?

A tiny macOS CLI that wraps your long-running command with `caffeinate` so the Mac stays awake, prints PID + battery + runtime, warns on low battery, and sends a native notification when the command is done.

Built for the new ritual of waiting on AI coding agents like Claude Code, Codex, OpenCode, Gemini CLI, Cursor, or any 30-minute test suite — without carrying a half-open laptop around like an aluminum taco.

## Install

```bash
git clone <REPO_URL>.git
cd laptop_taco
chmod +x taco
./taco --help
```

Optional, put it on your PATH:

```bash
ln -s "$(pwd)/taco" /usr/local/bin/taco
```

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

✅ Agent finished cooking
Runtime: 23m 18s
Exit code: 0

You may now close the taco.
```

## What's in this release

- One Bash file, ~150 lines, no dependencies
- `--help` and `--version` flags
- macOS-only guard (`uname` must be `Darwin`)
- Runs your command via `/bin/bash -lc` so pipes, `&&`, env vars, and aliases work
- `caffeinate -dim -w <pid>` keeps display, idle, and disk awake until your command exits
- Battery readout via `pmset -g batt`, with a < 20% warning
- Clean Ctrl+C handling — kills the child, stops caffeinate, exits 130
- macOS notification on finish via `osascript`
- Same exit code as the wrapped command (e.g., `taco "exit 42"` exits 42)
- Hours-aware runtime formatting (`2h 7m 5s`) for multi-hour runs
- `macos-latest` GitHub Actions smoke test

## Safety

Do not put a hot running laptop in a backpack. Do not block the vents. `caffeinate -dim` does not override Apple's closed-lid sleep behavior — if you close the lid, your Mac is probably going to sleep regardless.

## License

MIT.
