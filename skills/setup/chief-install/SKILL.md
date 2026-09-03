---
name: chief-install
description: Install the Chief framework into the current project. Installs AGENTS.md only — `.chief/` is created lazily on first need. Use when the user wants to set up the framework (e.g. "/chief-install" or "/chief-install canary").
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
   `/chief-upgrade` (which will explain the v4 → v5 migration, including that `.agents/agents/`
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
per-agent integration directory to populate anymore (no `.claude/agents/`, no `.github/agents/`
— those only ever existed to hold copies/symlinks of the now-deleted agent roster).

### 3. Clone and run setup script

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent <agent> --mode <mode>
```

The script installs:
- `AGENTS.md` — framework rules (fresh write if absent; appended in a
  `<!-- chief-framework:begin -->` block if `AGENTS.md` already exists)
- For `claude-code`: `CLAUDE.md` (symlink or copy of `AGENTS.md`)

It does **NOT** create `.chief/`. That is intentional.

If the setup script **fails completely** (non-zero exit code or crashes), skip to step 3b for
full manual install. Do NOT run `rm -rf .chief-agent-tmp` yet — it's needed for manual steps.

If the setup script succeeds, proceed to step 4.

### 3b. Full manual install (fallback if setup script fails)

Install `AGENTS.md` (Fresh-or-Append):

```bash
if [ ! -f AGENTS.md ]; then
  cp .chief-agent-tmp/template/AGENTS.md AGENTS.md
elif ! grep -qF "<!-- chief-framework:begin -->" AGENTS.md; then
  {
    echo ""
    echo "<!-- chief-framework:begin -->"
    cat .chief-agent-tmp/template/AGENTS.md
    echo "<!-- chief-framework:end -->"
  } >> AGENTS.md
fi
```

For `claude-code` only:

Link mode:
```bash
ln -s AGENTS.md CLAUDE.md
```

Copy mode:
```bash
cp AGENTS.md CLAUDE.md
```

For all other agents — no extra steps needed.

Skip any file that already exists (warn the user).

### 4. Verify installation

After the setup script or manual install completes, verify:

1. **`AGENTS.md` exists** and contains chief framework content (either the whole file or a
   `<!-- chief-framework:begin -->` block).
2. **Claude Code only** (if agent is `claude-code`): `CLAUDE.md` exists (symlink or copy
   depending on mode); if link mode, verify the symlink resolves correctly.

`.chief/` is **not** expected to exist after install — do not flag its absence. Neither is
`.agents/`, `.claude/agents/`, or `.github/agents/` — v5 doesn't create any of them.

### 5. Fix issues (fallback)

If any verification check fails, fix it manually:

- **Missing `AGENTS.md`** → re-run the Fresh-or-Append snippet from 3b
- **Missing `CLAUDE.md`** → create symlink (`ln -s AGENTS.md CLAUDE.md`) or copy depending on
  mode
- **Broken symlink** → remove and recreate
- **Wrong mode** (e.g. user wanted link but got copy) → remove and recreate with correct mode

### 6. Clean up

Ensure `.chief-agent-tmp` is removed:
```bash
rm -rf .chief-agent-tmp
```

### 7. Next steps

Tell the user:

1. Run `/chief-init` to bootstrap `.chief/project.md` with your tech stack and dev commands
   (this also confirms where planning artifacts should live — see `/chief-init`)
2. Review `AGENTS.md` and customize if needed
3. Start planning: `/chief-plan`

`.chief/` and its subfolders will be created automatically as you work — story folders, rule
subfolders, and reports are all written on first need.

## Important rules

- NEVER overwrite existing files without explicit user approval
- If `AGENTS.md` already exists and contains content, append the chief block; do NOT overwrite
- If a pre-v5 install is detected (`.agents/agents/chief-agent.md` present), suggest
  `/chief-upgrade` instead of proceeding — this skill installs v5 fresh, it doesn't migrate a
  v4 agent roster
- Always clean up `.chief-agent-tmp` even if the install is cancelled or fails
- If the setup script fails, attempt manual fixes before giving up
- Do NOT create `.chief/` at install — that is lazy
- Report all verification results to the user — even successful ones
