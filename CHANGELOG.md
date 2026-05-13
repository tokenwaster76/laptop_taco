# Changelog

All notable changes to this project are documented here.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet.

## [0.1.0] — 2026-05-13

The first version. Released because somebody had to.

### Added

- `taco` — one Bash script (~210 lines, including the new `doctor` subcommand). Runs your command, wraps it with `caffeinate -dim -w <pid>`, prints PID + battery + runtime, warns on low battery, traps `Ctrl+C`, fires a macOS notification on finish, propagates the wrapped command's exit code verbatim.
- `taco --help`, `taco --version`, `taco doctor`. Flags are handled before the Darwin guard, so they work on any OS.
- macOS-only Darwin guard with a clear refusal message on Linux / Windows.
- Hours-aware runtime formatter (`2h 7m 5s`) for multi-hour agent runs.
- `examples/demo-output.txt` — screenshot-ready terminal output.
- `.github/workflows/macos-smoke-test.yml` — runs on `macos-latest`, tests tool availability, syntax, `--help`, `--version`, `doctor`, happy path, exit codes 42 + 127, shell features, embedded quotes, the missing-command guard.
- `marketing/` — full launch kit (13 channel drafts, 18 scripts, 3 SVG assets, 5 top-level docs). See `marketing/README.md`.
- `.github/workflows/marketing-pack.yml` — manual workflow that builds a single-file launch pack as a downloadable artifact.
- `.github/workflows/auto-announce.yml` — on `release.published`, fans out to every API-safe channel whose secret is set (Mastodon, Bluesky, LinkedIn, Threads, X, DEV.to draft, Hashnode draft, Discord webhook, Slack webhook, repo metadata sync, Wayback archive). Reddit step is double-gated by `vars.REDDIT_AUTO_POST_OPT_IN == 'true'`.
- `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, issue + PR templates, `LAUNCH.md` go-public checklist.
- `Formula/laptop-taco.rb` — a starting-point Homebrew formula for a separate `homebrew-tap` repo.

### Notes

- The script's signal propagation depth is one level: `Ctrl+C` sends `SIGTERM` to the immediate `bash -lc` subshell. Well-behaved agents propagate further; misbehaving commands may orphan grandchildren. Documented in `SECURITY.md`.
- `caffeinate -dim` keeps display, idle timer, and disk awake but does **not** override Apple's lid-close sleep. The README and copy do not claim otherwise.

[Unreleased]: https://github.com/tokenwaster76/laptop_taco/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tokenwaster76/laptop_taco/releases/tag/v0.1.0
