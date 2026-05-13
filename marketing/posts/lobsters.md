# Lobsters

Only submit if you have an account in good standing and the topic genuinely fits. Lobsters readers are technical and skeptical; the post should be substance, not hype.

---

## Title

Laptop Taco: a tiny macOS caffeinate wrapper for long-running coding agents

## Suggested tags

release, unix, mac, show

## URL

<REPO_URL>

## Submission text

Small open-source utility. One Bash file, MIT, macOS-only. Wraps an arbitrary command with `caffeinate -dim -w <pid>` so the system stays awake until the child process exits, then sends a notification and exits with the child's exit code.

Motivation is the new pattern of long-running CLI coding agents that take 10+ minutes per task. The previous workaround was a different `caffeinate` invocation every time or a third-party menu-bar app; this is the smallest sensible automation of the obvious thing.

Design notes worth flagging:

- `--help` and `--version` are handled before the Darwin guard, so the script lints and reports its version on any platform (useful in CI).
- `set -u` and `set -o pipefail` but no `set -e`, because exit-code propagation from `wait` is the whole point.
- Battery parsing from `pmset -g batt` is best-effort and never fails the run; if it can't parse, it stays silent.
- `INT`/`TERM` trap kills the child cleanly, exits 130, and lets the `-w` flag handle caffeinate teardown.

GitHub Actions runs a `macos-latest` smoke test on every push (tool availability, syntax check, happy path, exit-code propagation for `taco "exit 42"`).

Happy to take feedback on the trap handling and exit-code propagation in particular.
