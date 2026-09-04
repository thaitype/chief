---
name: chief-install
description: Install the Chief framework into the current project. Writes AGENTS.md directly (clone target version, present it, confirm, write) — `.chief/` is created lazily on first need. Use when the user wants to set up the framework (e.g. "/chief-install" or "/chief-install canary").
---

Install the Chief framework into the current project.

This is a **lazy install**: only `AGENTS.md` is placed at install time. `.chief/`
(project.md, stories, rules) is created on demand by whichever `chief-*` skill first needs it —
run `/chief-init` to bootstrap project context, or just start with `/chief-plan`.

v5 has no `.agents/agents/` subagent roster to install — `chief-agent`, `builder-agent`,
`tester-agent`, and `answer-verifier-agent` are gone (see `docs/design/v5-ai-workflow.md`,
"All persistent subagents are deprecated"). What used to be persistent agent files are now
`chief-*` skills (`/chief-build`, `/chief-test`) that spawn their own throwaway subagents when
they need isolated context — nothing for this skill to install separately.

There is also no `scripts/setup.sh` to shell out to. Writing `AGENTS.md` is a small, judgment-
sensitive operation (don't clobber a file that might already have unrelated content) better
suited to an agent presenting a diff and asking than to a blind script — this skill does it
directly, the same way `/chief-upgrade` already does for updates.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → install the latest stable release (highest semver tag). Find it by running
  `git ls-remote --tags https://github.com/thaitype/chief.git`, strip `refs/tags/`, ignore
  `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v5.0.0`, etc. → specific tagged version

## Steps

### 1. Check for existing installation

Check if Chief is already installed by looking for these signals:

1. `AGENTS.md` at root contains the keyword "Chief" (check file content, not just existence —
   this file may exist from other setups).
2. `.agents/agents/chief-agent.md` exists — a **v4-or-earlier** install signal. If found, tell
   the user this project has a pre-v5 install with the deprecated agent roster; offer
   `/chief-upgrade` (which explains the v4 → v5 migration, including that `.agents/agents/`
   goes away) rather than proceeding here.

If **neither** matches → proceed.

### 2. Ask which coding agent

Supported agents: `claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`,
`windsurf`, `kiro`, `aider`.

For `claude-code` only, also ask install mode:
- **link** (recommended) — symlinks `CLAUDE.md` to `AGENTS.md`
- **copy** — copies instead of symlinking
- On Windows, link mode requires Developer Mode enabled and
  `git config --global core.symlinks true`. If unavailable, suggest copy mode.

For all other agents, mode doesn't apply — they read `AGENTS.md` directly, and there's no
per-agent integration directory to populate (no `.claude/agents/`, no `.github/agents/` — those
only ever existed to hold copies/symlinks of the now-deleted agent roster).

### 3. Fetch the target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief.git .chief-agent-tmp
```

Read `.chief-agent-tmp/template/AGENTS.md` — this is what gets installed.

### 4. Present and confirm

If the target `AGENTS.md` doesn't exist yet, show the full content of
`.chief-agent-tmp/template/AGENTS.md` as what will be written fresh.

If it already exists, show a diff (`diff AGENTS.md .chief-agent-tmp/template/AGENTS.md`) and
explain: everything **outside** the `<!-- chief-framework:begin -->` /
`<!-- chief-framework:end -->` markers (or, for a file with no markers at all, everything
outside a `## Project Rules` section) is the user's own and will be left untouched; only the
framework-owned block gets written or updated.

Ask once: "Write this?" Wait for approval before touching anything.

### 5. Write

- **No existing `AGENTS.md`** → copy `.chief-agent-tmp/template/AGENTS.md` to `AGENTS.md`
  as-is.
- **Existing, with `<!-- chief-framework:begin -->` markers already present** → replace
  everything between the markers with the template's framework block content. Leave everything
  outside the markers untouched.
- **Existing, no markers** → append the template's framework block
  (`<!-- chief-framework:begin -->` through `<!-- chief-framework:end -->`) to the end of the
  file, on its own blank line. Do not touch existing content above it.

### 6. Claude Code integration

For `claude-code` only:

- **Link mode**: `ln -s AGENTS.md CLAUDE.md` (skip if `CLAUDE.md` already exists — report it as
  skipped, don't overwrite).
- **Copy mode**: `cp AGENTS.md CLAUDE.md` (same skip-if-exists rule).

For every other agent: nothing further — they read `AGENTS.md` directly.

### 7. Verify

1. `AGENTS.md` exists and contains chief framework content (either the whole file, for a fresh
   write, or the `<!-- chief-framework:begin -->` block, for an append/update).
2. **Claude Code only**: `CLAUDE.md` exists (symlink or copy per mode); if link mode, the
   symlink resolves.

`.chief/` is **not** expected to exist after install — do not flag its absence. Neither is
`.agents/`, `.claude/agents/`, or `.github/agents/` — v5 doesn't create any of them.

### 8. Clean up

```bash
rm -rf .chief-agent-tmp
```

Always, even if the install was cancelled at step 4.

### 9. Next steps

Tell the user:

1. Run `/chief-init` to bootstrap `.chief/project.md` with your tech stack and dev commands
   (this also confirms where planning artifacts should live)
2. Optionally run `/setup-agent-behavior` if you want general (non-Chief) agent-conduct rules
   binding every session
3. Review `AGENTS.md`'s Project Rules section and customize if needed
4. Start planning: `/chief-plan`, or run `/ask-chief` if unsure where to start

`.chief/` and its subfolders will be created automatically as you work — story folders, rule
subfolders, and reports are all written on first need.

## Important rules

- NEVER overwrite existing content outside the framework markers (or outside `## Project
  Rules`, for a marker-less file) without explicit user approval.
- NEVER skip the confirmation in step 4 — always show what will be written before writing it.
- If a pre-v5 install is detected (`.agents/agents/chief-agent.md` present), suggest
  `/chief-upgrade` instead of proceeding — this skill installs v5 fresh, it doesn't migrate a
  v4 agent roster.
- Always clean up `.chief-agent-tmp` even if the install is cancelled or fails.
- Do NOT create `.chief/` at install — that is lazy.
- Report all verification results to the user — even successful ones.
