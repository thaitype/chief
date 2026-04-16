---
name: install-chief
description: Install the Chief Agent Framework into the current project. Detects coding agent, asks for install mode, copies framework files, and sets up symlinks or copies. Use when the user wants to set up the framework (e.g. "/install-chief" or "/install-chief canary").
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

1. **Which coding agent?** — Claude Code, OpenCode, or other
2. **Install mode?** (only for coding agents with their own directory, e.g. Claude Code)
   - **link** (recommended) — symlinks from coding-agent-specific directory to `.agents/`
   - **copy** — copies files instead of symlinking

OpenCode reads `.agents/` directly and needs no install mode.

### 3. Clone the target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
```

### 4. Copy core files

Copy from `.chief-agent-tmp/` into the project:

```bash
cp -r .chief-agent-tmp/.agents .agents
cp -r .chief-agent-tmp/.chief .chief
cp .chief-agent-tmp/AGENTS.md AGENTS.md
```

Skip any file or directory that already exists (warn the user).

### 5. Set up coding-agent-specific rules file

Based on the chosen mode:

**Link mode:**
```bash
ln -s AGENTS.md CLAUDE.md
```

**Copy mode:**
```bash
cp AGENTS.md CLAUDE.md
```

### 6. Set up coding agent integration

**Claude Code** — create `.claude/agents/` and `.claude/skills/` directories, then add entries for each agent and skill:

Link mode:
```bash
mkdir -p .claude/agents .claude/skills
ln -s ../../.agents/agents/chief-agent.md .claude/agents/chief-agent.md
ln -s ../../.agents/agents/builder-agent.md .claude/agents/builder-agent.md
ln -s ../../.agents/agents/tester-agent.md .claude/agents/tester-agent.md
ln -s ../../.agents/agents/review-plan-agent.md .claude/agents/review-plan-agent.md
ln -s ../../.agents/skills/grill-me .claude/skills/grill-me
```

Copy mode:
```bash
mkdir -p .claude/agents .claude/skills
cp .agents/agents/*.md .claude/agents/
cp -r .agents/skills/* .claude/skills/
```

Skip entries that already exist in `.claude/` (warn the user).

**OpenCode** — no action needed, it reads `.agents/` directly.

### 7. Clean up

```bash
rm -rf .chief-agent-tmp
```

### 8. Next steps

Tell the user:

1. Edit `.chief/project.md` with your project details (or run `chief-agent: use grill-me to help me fill in project.md`)
2. Review `AGENTS.md` and customize if needed
3. Start using: ask chief-agent to plan your first milestone

## Important rules

- NEVER overwrite existing files without explicit user approval
- If `.agents/` or `AGENTS.md` already exist, suggest `/upgrade-chief` instead
- Always clean up `.chief-agent-tmp` even if the install is cancelled
- Skip existing files in `.claude/` to avoid overwriting user's existing agent configs
