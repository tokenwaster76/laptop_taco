# Hacker News — Show HN

Submit manually at https://news.ycombinator.com/submit. Do not solicit upvotes. Do not post and disappear — be ready to answer questions for the first few hours after submission.

---

## Title

Show HN: Laptop Taco – keep your Mac awake while coding agents run

## URL

<REPO_URL>

## First comment (post immediately after submission)

I made this after seeing the ridiculous "half-open laptop taco" behavior from people trying to keep long-running coding agents alive.

It is intentionally small: one Bash script, macOS-only, wraps a command with `caffeinate`, prints status, warns on battery, and exits with the child process code.

Not trying to be a full power-management app. Mostly a tiny useful joke.

Happy to take feedback on the script, the safety warnings, or what other AI-agent quality-of-life things should exist.
