<!--
Before opening: read CONTRIBUTING.md. Tiny + funny + useful is the bar.
-->

## What changed

<!-- 1-3 bullets. What's different now. -->

-
-

## Why

<!-- The user-facing reason. Not "refactored for cleanliness." -->



## How I verified

<!-- Check the boxes that apply. -->

- [ ] `bash -n taco` still clean
- [ ] `./taco --help` / `--version` / `doctor` still work
- [ ] Ran `./taco "echo cooking && sleep 1 && echo done"` on a real Mac
- [ ] Ran `./taco "exit 42"` and observed exit code 42
- [ ] Tested Ctrl+C kills the child cleanly
- [ ] If touching `marketing/`: `marketing/scripts/audit-tree.sh` is clean
- [ ] If touching workflows: `python3 -c "import yaml; yaml.safe_load(open(...))"` passes

## Size

<!-- Roughly how many net lines added/removed in `taco`. Tiny is the point. -->

- Lines added:
- Lines removed:

## Taco-shaped?

<!-- Tick yes if your change fits these. Untick if it doesn't and tell us why. -->

- [ ] No new dependencies
- [ ] No new config file
- [ ] No new daemon, menu-bar app, or background process
- [ ] No telemetry, analytics, or auto-updater
- [ ] No false portability claims (macOS-only stays macOS-only)
- [ ] Safety warnings preserved
