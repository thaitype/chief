---
name: dump-commit
description: Quick commit all files with a short 1-line message. Saves tokens by skipping detailed diff analysis. Use when the user wants a fast save (e.g. "/dump-commit" or "/dump-commit fix upgrade flow").
---

Commit all current changes with minimal token usage.

## Arguments

Optional: a commit message string. If provided, use it as-is. If not provided, auto-generate from file names.

## Steps

### 1. Check for secrets

Run `git status`. If any staged or untracked file matches these patterns, **warn the user and STOP** — do not commit:

- `.env*`
- `*credentials*`
- `*secret*`
- `*.pem`
- `*.key`

### 2. Stage all files

```bash
git add -A
```

### 3. Generate or use commit message

If the user provided a message in the arguments → use it directly.

If no message was provided, generate a 1-line message using these sources (in priority order):

1. **Recent conversation context** — if the conversation contains clear context about what was just done (e.g. "add retro-chief skill", "fix upgrade script"), use that to write a meaningful message.
2. **File names from `git diff --cached --stat`** — if no conversation context, fall back to summarizing changed file names (e.g. `wip: update chief-agent, plan-milestone, upgrade.sh`).

Do NOT read file content or full diffs. Keep the message under 72 characters.

### 4. Commit

```bash
git commit -m "<message>"
```

## Rules

- NEVER read file content or full diffs — only `--stat` output
- NEVER ask the user to review the message — just commit
- NEVER add Co-Authored-By or multi-line messages
- If nothing to commit (clean working tree), say so and stop
