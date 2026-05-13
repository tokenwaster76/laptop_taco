# Security policy

## Reporting a vulnerability

Open a private security advisory:

https://github.com/tokenwaster76/laptop_taco/security/advisories/new

I respond within **5 business days**. Critical fixes ship within 14 days, lower-severity issues within 30. The whole project is a ~150-line Bash script plus a small marketing kit — the attack surface is intentionally small.

Please do **not** open a public issue for a security bug. Use the advisory link above.

## What `taco` does (and doesn't)

`taco` is a Bash wrapper that runs an arbitrary command in a child shell and inhibits macOS sleep until that command exits. Its security model is intentionally minimal:

1. **It runs whatever you tell it to.** `./taco rm -rf /` will run `rm -rf /`. The point of the tool is to execute your command faithfully. Documented in `taco --help`. Do not pass `taco` input you do not trust.
2. **No privilege escalation.** No `sudo`, no `setuid`, no `setgid`. It runs as your user.
3. **No network calls.** No telemetry, no analytics, no auto-updater. The only external call is `osascript` for the local macOS notification.
4. **Signal handling.** `SIGINT` and `SIGTERM` send `SIGTERM` to the immediate child shell (`bash -lc`). Well-behaved subprocesses propagate the signal further; a misbehaving wrapped command may orphan grandchildren. This is a documented limitation, not a vulnerability.
5. **Exit-code propagation.** The child's exit code is propagated verbatim. The script itself does not alter or mask it.

### Out of scope for the `taco` script

- Sandboxing the wrapped command. The whole job is to run it.
- Preventing the wrapped command from spawning long-lived children that survive `Ctrl+C`.
- Thermal protection. `caffeinate` keeps the OS awake; it does not change the laws of physics. Do not put a hot laptop in a backpack.
- Lid-closed sleep. `caffeinate -dim` does **not** override Apple's lid-close behavior, and the README does not claim otherwise.

## What `marketing/scripts/` does

Each script under `marketing/scripts/` POSTs to exactly one third-party service using credentials you provide via environment variables. Hardening summary:

| Control | Where |
| --- | --- |
| All endpoints HTTPS, no `-k` / `--insecure` | every `curl` invocation |
| `--max-time 60` on every `curl` (wayback uses `-m 30`) | every script |
| Credentials read from environment, never from argv | all `post-*` / `create-*` scripts |
| JSON payloads built in Python3 (`json.dumps`), never by shell string concatenation | every script that POSTs JSON |
| `.env` file parsed line-by-line by a strict `KEY=value` regex, **never** `source`d | `generate-launch-pack.sh` |
| DEV.to + Hashnode hard-coded to draft | `create-devto-draft.sh`, `create-hashnode-draft.sh` |
| Reddit script hard-gated by `REDDIT_AUTO_POST_OPT_IN=true` + single-sub + 60-second rate guard | `post-reddit.sh` |
| Webhooks POST only to URLs you paste | `post-discord.sh`, `post-slack.sh` |
| One post per launch, no loops, no retries on success | every script |
| Workflow runs only on `release.published` or manual `workflow_dispatch` (no cron) | `.github/workflows/auto-announce.yml` |
| Secrets sourced from GitHub Actions secrets in CI | `auto-announce.yml` |

### Secret storage

- **Locally**: `marketing/launch-config.env` (gitignored).
- **In CI**: GitHub repository secrets, `Settings → Secrets and variables → Actions`.
- **Tokens are never logged.** The workflow does not `echo` secret values; the scripts only echo the public response URLs.
- **LinkedIn tokens expire** after ~60 days; re-run `marketing/scripts/get-linkedin-token.sh` when LinkedIn returns 401.
- **Reddit's "script app" OAuth uses a password grant** — pass a unique, non-2FA account if you can. The password is sent over HTTPS once per invocation; nothing is persisted by the script.

### Out of scope for the marketing kit

- Multi-user / multi-tenant access control. This is a single-maintainer tool.
- Secret rotation reminders.
- HSM-backed key storage.
- Defense against a maintainer with a compromised local machine. If your dev laptop is compromised, the .env file on it is compromised too.

## What is **not** a security issue

- The wrapped command runs whatever you put on the command line. That is the feature.
- `caffeinate` keeping the system awake. Standard macOS API.
- The `marketing/` folder being public — see [`marketing/MARKETING-IS-PUBLIC.md`](marketing/MARKETING-IS-PUBLIC.md).
- Anyone forking the repo and running the kit with their own credentials — MIT license.
- The repo's `Mode: cracked-open chaos` startup banner.

## Supported versions

| Version | Status |
| --- | --- |
| `v0.1.x` | ✅ supported |
| pre-release / branch builds | ❌ not supported |

## How to verify the tree before each release

```bash
# all scripts syntax-check
for f in marketing/scripts/*.sh; do bash -n "$f"; done
bash -n taco

# no third-party authorship strings sneak in
marketing/scripts/audit-tree.sh

# all workflow YAMLs parse
python3 -c "import yaml; [yaml.safe_load(open(f)) for f in [
  '.github/workflows/macos-smoke-test.yml',
  '.github/workflows/marketing-pack.yml',
  '.github/workflows/auto-announce.yml']]"

# every API poster fails-clean with no env
for f in marketing/scripts/{post,create,set}-*.sh marketing/scripts/get-linkedin-token.sh; do
  echo "== $f =="
  "$f" 2>&1 | head -3
  echo
done
```
