---
name: install-chief
description: Install the Chief Agent Framework into the current project. Uses setup.sh as the primary method, then verifies and fixes manually if needed. Use when the user wants to set up the framework (e.g. "/install-chief" or "/install-chief canary").
---

Install the Chief Agent Framework into the current project.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → install the latest stable release (highest semver tag). Find it by running `git ls-remote --tags https://github.com/thaitype/chief-agent-framework.git`, strip `refs/tags/`, ignore `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v1.0.0`, `v2.0.0`, etc. → specific tagged version

## Steps

### 1. Check for existing installation

Check if the Chief Agent Framework is already installed by looking for these signals:

1. `.agents/agents/chief-agent.md` exists
2. `.chief/` directory exists
3. `AGENTS.md` or `CLAUDE.md` at root contains the keyword "Chief Agent Framework" (check file content, not just existence — these files may exist from other setups)

If **any** of these match → the framework is likely already installed. Warn the user and suggest upgrading instead. Show them:
```
npx skills@latest add thaitype/chief-agent-framework --skill upgrade-chief
/upgrade-chief
```
Do NOT proceed unless the user explicitly confirms they want a fresh install.

If **none** match → proceed.

### 2. Ask coding agent and install mode

Ask the user:

1. **Which coding agent?** — Supported agents: `claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`
2. **Install mode?** (only relevant for `claude-code`)
   - **link** (recommended) — symlinks from `.claude/` to `.agents/`
   - **copy** — copies files instead of symlinking
   - For all other agents, mode does not affect behavior since they read `AGENTS.md` and `.agents/` directly

### 3. Clone and run setup script

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent <agent> --mode <mode>
rm -rf .chief-agent-tmp
```

### 4. Verify installation

After the setup script completes, verify that the installation is correct:

1. **Core files exist:**
   - `.agents/agents/chief-agent.md`
   - `.agents/agents/builder-agent.md`
   - `.agents/agents/tester-agent.md`
   - `.agents/agents/review-plan-agent.md`
   - `.agents/skills/grill-me/SKILL.md`
   - `.chief/project.md`
   - `.chief/_rules/`
   - `AGENTS.md`

2. **Claude Code only** (if agent is `claude-code`):
   - `CLAUDE.md` exists (symlink or copy depending on mode)
   - `.claude/agents/` contains entries for all 4 agents
   - `.claude/skills/` contains entry for grill-me
   - If link mode: verify symlinks resolve correctly

### 5. Fix issues (fallback)

If any verification check fails, fix it manually:

- **Missing core file** → copy from `.chief-agent-tmp/` if it still exists, otherwise clone again and copy the specific file
- **Missing CLAUDE.md** → create symlink (`ln -s AGENTS.md CLAUDE.md`) or copy depending on mode
- **Missing .claude/ symlinks** → create them individually:
  ```bash
  mkdir -p .claude/agents .claude/skills
  ln -s ../../.agents/agents/<file>.md .claude/agents/<file>.md
  ln -s ../../.agents/skills/<skill> .claude/skills/<skill>
  ```
- **Broken symlink** → remove and recreate
- **Wrong mode** (e.g. user wanted link but got copy) → remove and recreate with correct mode

### 6. Clean up

Ensure `.chief-agent-tmp` is removed:
```bash
rm -rf .chief-agent-tmp
```

### 7. Next steps

Tell the user:

1. Edit `.chief/project.md` with your project details (or run `chief-agent: use grill-me to help me fill in project.md`)
2. Review `AGENTS.md` and customize if needed
3. Start using: ask chief-agent to plan your first milestone

## Important rules

- NEVER overwrite existing files without explicit user approval
- If the framework is already installed, suggest `/upgrade-chief` instead
- Always clean up `.chief-agent-tmp` even if the install is cancelled or fails
- If the setup script fails, attempt manual fixes before giving up
- Report all verification results to the user — even successful ones
