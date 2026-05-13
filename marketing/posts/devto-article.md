---
title: I built a tiny CLI for the "laptop taco" era of AI coding agents
published: false
tags: ai, cli, macos, opensource
canonical_url:
---

## The weird new behavior

It is 2026 and developers are walking around like glassy-eyed cyborgs.

Look at any coffee shop. You'll spot it. Someone striding to the counter with a MacBook tucked under their arm, lid wedged maybe halfway open. Not closed. Not open. Half. Like an aluminum taco. They are not striking a pose. They are simply trying to keep an AI coding agent alive while they pretend to be a normal human in public.

The agent inside is on its 19th-minute refactor of a config loader they will never look at again. The lid stays cracked because closing it kills the process. The fan is screaming. The aluminum is warm enough to brand a steak. The dignity is medium-rare.

I refused to participate in this lid-ajar nightmare.

## Why this exists

The fix has been built into macOS for over a decade.

It is one command. It is called `caffeinate`. It already does the right thing. The only friction is that you have to remember it exists, type it correctly, remember to stop it, and want to babysit a terminal. So everyone just keeps carrying tiny hot tacos around and ignoring the thermal warnings.

I wrote 150 lines of Bash that automate the obvious thing. It is called **Laptop Taco**.

## What Laptop Taco does

```bash
./taco claude
./taco codex
./taco opencode
./taco "npm test"
./taco "echo cooking && sleep 3 && echo done"
```

Each invocation:

1. Refuses to run on anything other than macOS — `caffeinate` is the dependency, there is no honest fallback for other platforms.
2. Launches your command via `/bin/bash -lc` so pipes, `&&`, env vars, and aliases all work.
3. Starts `/usr/bin/caffeinate -dim -w <child_pid>` so the display, idle timer, and disk stay awake until your command exits.
4. Prints PID, start time, battery percentage, and a one-line mode banner.
5. Warns you if the battery is below 20%.
6. Traps Ctrl+C so it kills the child cleanly and stops `caffeinate`.
7. Sends a native macOS notification when the command finishes.
8. Exits with the same code your command returned — `taco "exit 42"` exits 42.
9. Formats runtime with hours when it crosses 60 minutes, because the killer use case is multi-hour agent runs.

That is the whole tool. No flags beyond `--help` and `--version`. No config file. No daemon. No menu-bar icon. No telemetry.

## Why it is intentionally small

Half the value of a meme tool is that you can read all of it in one sitting and trust it. The whole script is one file, MIT licensed, ~150 lines including the help text. There is no package manager step, no dependency to upgrade, no auth flow, no telemetry, no auto-updater, no Sentry, no `posthog.capture`. You clone, `chmod +x taco`, and you are running it 15 seconds later.

If you want power management, use a real power-management product. If you want session multiplexing on a remote box, use tmux. Laptop Taco does one tiny job and gets out of the way.

## Code usage examples

```bash
# wrap a long-running agent
./taco claude

# wrap a quoted shell command
./taco "npm test"

# wrap something with shell features
./taco "echo cooking && sleep 30 && echo done"

# flags work on any platform (handled before the Darwin guard)
./taco --help
./taco --version
```

The output is intentionally screenshot-friendly:

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
```

## What it is not

- Not a GUI app
- Not a cloud service
- Not a replacement for tmux or a remote dev box
- Not guaranteed closed-lid support — Apple's lid-close sleep is its own beast and `caffeinate` does not override it
- Not a serious power-management product
- Not responsible for you cooking your laptop in a backpack

## Safety note

Running a hot laptop inside a closed backpack is bad. Vents matter. Thermal throttling matters. Lithium batteries matter. Laptop Taco keeps the OS awake. It does not change the laws of physics.

If you want your agent to keep working when you are away from the desk, the responsible answer is not "carry a half-open laptop." It is a small home Mac that stays on a desk, a remote dev box, or simply waiting for the agent to finish before you leave.

## GitHub

<REPO_URL>

If you build something funnier with the same shape — same vibe, one file, macOS, one specific developer ritual — I want to see it.
