---
title: Laptop Taco 🌮
description: A tiny macOS CLI for the new ritual of waiting on AI coding agents.
layout: default
---

# Laptop Taco 🌮

**For when your agent is cooking and you need to catch a bus.**

People are wandering coffee shops clutching half-open MacBooks at exactly 45° because their AI coding agents refuse to die quietly. The lid stays cracked because closing it kills the process. The aluminum is warm enough to brand a steak. The dignity is medium-rare.

Laptop Taco is one Bash script that wraps your long-running command with macOS `caffeinate`, prints PID + battery + runtime, warns on low battery, and pings you when the agent is done cooking. Same exit code as your command.

```bash
./taco claude
./taco codex
./taco "npm test"
```

No app. No account. No cloud. No subscription. ~210 lines of Bash. MIT.

## Install

```bash
git clone https://github.com/tokenwaster76/laptop_taco.git
cd laptop_taco
chmod +x taco
./taco --help
```

Or with Homebrew once the tap is published:

```bash
brew install tokenwaster76/tap/laptop-taco
```

## What it does

- Wraps your command in `caffeinate -dim -w <pid>` so the system stays awake until the process exits
- Prints PID, start time, battery
- Warns on battery below 20%
- Sends a macOS notification when the command finishes
- Exits with the same code as the wrapped command
- `taco doctor` reports your macOS setup

## What it isn't

- A GUI app
- A cloud service
- A replacement for tmux or a remote dev box
- Guaranteed closed-lid support — `caffeinate -dim` does **not** override Apple's lid-close sleep
- Responsible for you cooking your laptop in a backpack

## Safety

Do not put a hot running laptop in a backpack. Vents matter. Thermal throttling matters. Lithium batteries matter. Laptop Taco keeps the OS awake. It does not change the laws of physics.

## Links

- **Source:** [github.com/tokenwaster76/laptop_taco](https://github.com/tokenwaster76/laptop_taco)
- **Release notes:** [latest release](https://github.com/tokenwaster76/laptop_taco/releases/latest)
- **Issues:** [github.com/tokenwaster76/laptop_taco/issues](https://github.com/tokenwaster76/laptop_taco/issues)
- **License:** MIT
