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

For **lite** installs:
1. `AGENTS.md` at root contains the keyword "Chief Agent Framework"

For **full** installs (or if profile is unknown at this point, check all):
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

1. **Which profile?** — `lite` or `full` (default: lite)
   - **lite** — Single `AGENTS.md` with core principles and project-specific rules section. No `.chief/`, `.agents/`, or skills. Best for prototypes, scripts, personal tools.
   - **full** — Full framework with `.chief/`, `.agents/`, subagents, skills, milestones. Best for multi-milestone projects, shared codebases.

2. **Which coding agent?** — Supported agents: `claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`

3. **Install mode?** (relevant for `claude-code` and `copilot` in **full** profile; for **lite** profile, only relevant for `claude-code` to set up the `CLAUDE.md` symlink)
   - **link** (recommended) — symlinks from agent-specific directory to `.agents/` (full) or `AGENTS.md` (lite, claude-code only)
   - **copy** — copies files instead of symlinking
   - On Windows, link mode requires Developer Mode enabled and `git config --global core.symlinks true`. If unavailable, suggest copy mode.
   - For lite profile with agents other than `claude-code`, mode does not apply since those agents read `AGENTS.md` directly.
   - For full profile with agents other than `claude-code` and `copilot`, mode does not affect behavior since they read `AGENTS.md` and `.agents/` directly.

### 3. Clone and run setup script

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent <agent> --mode <mode>
```

If profile is `lite`, skip the setup script entirely and proceed directly to step 3b for manual install.

If the setup script **fails completely** (non-zero exit code or crashes), skip to step 3b for full manual install. Do NOT run `rm -rf .chief-agent-tmp` yet — it's needed for manual steps.

If the setup script succeeds, proceed to step 4.

### 3b. Manual install

**Lite profile:**

```bash
# Core file only
cp .chief-agent-tmp/template/AGENTS.lite.md AGENTS.md
```

For `claude-code` only (lite mode):

Link mode:
```bash
ln -s AGENTS.md CLAUDE.md
```

Copy mode:
```bash
cp AGENTS.md CLAUDE.md
```

For `copilot` — no special setup in lite mode (lite installs have no `.agents/` to copy, so skip).

For all other agents — no extra steps needed in lite mode.

---

**Full profile (fallback if setup script fails):**

```bash
# Core files (source is under template/)
cp -r .chief-agent-tmp/template/.agents .agents
cp -r .chief-agent-tmp/template/.chief .chief
cp .chief-agent-tmp/template/AGENTS.full.md AGENTS.md
```

For `claude-code` only, set up Claude Code integration:

Link mode:
```bash
ln -s AGENTS.md CLAUDE.md
mkdir -p .claude/agents .claude/skills
for f in .agents/agents/*.md; do ln -s "../../$f" ".claude/agents/$(basename "$f")"; done
for d in .agents/skills/*/; do ln -s "../../$d" ".claude/skills/$(basename "$d")"; done
```

Copy mode:
```bash
cp AGENTS.md CLAUDE.md
mkdir -p .claude/agents .claude/skills
cp .agents/agents/*.md .claude/agents/
cp -r .agents/skills/* .claude/skills/
```

For `copilot` only, set up GitHub Copilot integration:

Link mode:
```bash
mkdir -p .github/agents
for f in .agents/agents/*.md; do ln -s "../../$f" ".github/agents/$(basename "$f")"; done
```

Copy mode:
```bash
mkdir -p .github/agents
cp .agents/agents/*.md .github/agents/
```

For all other agents — no extra steps needed.

For non-`claude-code` agents (full profile), ask the user for model names:
1. **Thinking Model** (for chief-agent, e.g. `o3`, `gemini-2.5-pro`)
2. **Coding Model** (for builder/tester/review-plan, e.g. `gpt-4.1`, `gemini-2.5-flash`)

Replace `${thinking_model}` with the Thinking Model in chief-agent, and `${coding_model}` with the Coding Model in all other agent files. For `claude-code`, auto-replace with `opus` and `sonnet` (no prompt needed). For `copilot`, update files in `.github/agents/`. For other agents, update files in `.agents/agents/`.

Skip any file or directory that already exists (warn the user).

### 4. Verify installation

**Lite profile:**

1. `AGENTS.md` exists and contains "Chief Agent Framework"
2. If agent is `claude-code`: `CLAUDE.md` exists (symlink or copy depending on mode)
3. No `.chief/` or `.agents/` directories exist (confirm they were not accidentally created)

**Full profile:**

After the setup script or manual install completes, verify that the installation is correct:

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

3. **Copilot only** (if agent is `copilot`):
   - `.github/agents/` contains entries for all 4 agents (symlinks or copies depending on mode)
   - If link mode: verify symlinks resolve correctly
   - Model values have been replaced if the user provided model names

### 5. Fix issues (fallback)

If any verification check fails, fix it manually:

- **Missing core file** → copy from `.chief-agent-tmp/template/` if it still exists, otherwise clone again and copy the specific file
- **Missing CLAUDE.md** → create symlink (`ln -s AGENTS.md CLAUDE.md`) or copy depending on mode
- **Missing .claude/ symlinks** → create them individually (full profile only):
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

**Lite profile:**

Tell the user:

1. Add your project-specific rules to the bottom section of `AGENTS.md`
2. Optional: install grill-me skill with `npx skills@latest add thaitype/chief-agent-framework --skill grill-me`
3. When your project grows, upgrade with `/upgrade-chief`

**Full profile:**

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
