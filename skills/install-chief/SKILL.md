---
name: install-chief
description: Install the Chief Agent Framework into the current project. Uses setup.sh as the primary method, then verifies and fixes manually if needed. Use when the user wants to set up the framework (e.g. "/install-chief" or "/install-chief canary").
---

Install the Chief Agent Framework into the current project.

## Arguments

- First positional argument: target version (branch or tag). Optional.
- Optional flag: `--preset lite|full`.
  - `full` is default (backward compatible).
  - `lite` installs lightweight preset.

Version resolution:
- No version argument: install latest stable release (highest semver tag). Find via `git ls-remote --tags https://github.com/thaitype/chief-agent-framework.git`, strip `refs/tags/`, ignore `^{}`, pick highest semver.
- `canary`: latest canary branch.
- `v1.0.0`, `v2.0.0`, etc.: specific tag.

Preset behavior:
- `--preset full`:
  - installs full framework (`.agents/`, `.chief/`, full skills)
  - installs `AGENTS.full.md` as project `AGENTS.md`
- `--preset lite`:
  - installs only `.agents/agents/sa-agent.md` and `.agents/agents/review-plan-agent.md`
  - installs `AGENTS.lite.md` as project `AGENTS.md`
  - installs `CHIEF.md` at project root
  - does not install `.chief/`
  - does not install grill-me skill

`--preset` is installation scope. `--mode` remains symlink behavior for Claude Code (`link|copy`).

## Steps

### 1. Check for existing installation

Check these signals:
1. `.agents/agents/chief-agent.md` exists
2. `.chief/` directory exists
3. `AGENTS.md` or `CLAUDE.md` at root contains keyword "Chief Agent Framework"

If any match: warn that framework likely exists and suggest upgrade:
```bash
npx skills@latest add thaitype/chief-agent-framework --skill upgrade-chief
/upgrade-chief
```
Do not proceed unless user explicitly confirms fresh install.

If none match: continue.

### 2. Ask coding agent, preset, and install mode

Ask the user:
1. Which coding agent? (`claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`)
2. Which preset? (`full` default, or `lite`)
3. Install mode for Claude Code only: `link` (recommended) or `copy`

For non-Claude agents, mode does not affect behavior.

### 3. Clone and run setup script

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent <agent> --preset <preset> --mode <mode>
```

If setup script fails completely, go to step 3b. Keep `.chief-agent-tmp` for fallback.

### 3b. Manual install fallback

If setup fails, install manually based on preset.

Full preset:
```bash
cp -r .chief-agent-tmp/.agents .agents
cp -r .chief-agent-tmp/.chief .chief
cp .chief-agent-tmp/AGENTS.full.md AGENTS.md
```

Lite preset:
```bash
mkdir -p .agents/agents
cp .chief-agent-tmp/.agents/agents/sa-agent.md .agents/agents/
cp .chief-agent-tmp/.agents/agents/review-plan-agent.md .agents/agents/
cp .chief-agent-tmp/AGENTS.lite.md AGENTS.md
cp .chief-agent-tmp/.chief/_template/CHIEF.md CHIEF.md
```

Claude Code only:

Link mode:
```bash
ln -s AGENTS.md CLAUDE.md
mkdir -p .claude/agents
for f in .agents/agents/*.md; do ln -s "../../$f" ".claude/agents/$(basename "$f")"; done
```
If preset is `full`, also link skills:
```bash
mkdir -p .claude/skills
for d in .agents/skills/*/; do ln -s "../../$d" ".claude/skills/$(basename "$d")"; done
```

Copy mode:
```bash
cp AGENTS.md CLAUDE.md
mkdir -p .claude/agents
cp .agents/agents/*.md .claude/agents/
```
If preset is `full`, also copy skills:
```bash
mkdir -p .claude/skills
cp -r .agents/skills/* .claude/skills/
```

For non-Claude agents: no extra steps.

Skip any file or directory that already exists and warn the user.

### 4. Verify installation

Preset-specific checks:

Full preset:
- `.agents/agents/chief-agent.md`
- `.agents/agents/builder-agent.md`
- `.agents/agents/tester-agent.md`
- `.agents/agents/review-plan-agent.md`
- `.agents/agents/sa-agent.md`
- `.agents/skills/grill-me/SKILL.md`
- `.chief/project.md`
- `.chief/_rules/`
- `AGENTS.md`

Lite preset:
- `.agents/agents/sa-agent.md`
- `.agents/agents/review-plan-agent.md`
- `.agents/agents/chief-agent.md` does not exist
- `.chief/` does not exist
- `CHIEF.md` exists
- `AGENTS.md` exists

Claude Code only:
- `CLAUDE.md` exists (symlink for link mode, copy for copy mode)
- `.claude/agents/` entries match preset:
  - full: all installed agents
  - lite: only `sa-agent.md` and `review-plan-agent.md`
- `.claude/skills/` exists only for full preset

### 5. Fix issues

If verification fails, fix manually:
- Missing files: copy from `.chief-agent-tmp` (or re-clone target version)
- Missing `CLAUDE.md`: create symlink or copy based on selected mode
- Missing `.claude` entries: create/copy individually
- Broken symlinks: remove and recreate
- Wrong preset installed: reinstall with intended `--preset`
- Wrong mode installed: recreate links/copies with intended `--mode`

### 6. Clean up

Always remove temp clone:
```bash
rm -rf .chief-agent-tmp
```

### 7. Next steps

Full preset:
1. Edit `.chief/project.md` with project details
2. Review `AGENTS.md` and customize if needed
3. Start using: ask chief-agent to plan your first milestone

Lite preset:
1. Edit `CHIEF.md` with project context
2. Review `AGENTS.md` and customize if needed
3. Start using: ask sa-agent to grill your design decisions
4. Upgrade path: `/upgrade-chief --preset full`

## Important rules

- Never overwrite existing files without explicit user approval
- If framework already appears installed, suggest `/upgrade-chief` first
- Always clean up `.chief-agent-tmp`, even on failure or cancellation
- If setup fails, attempt manual fallback before giving up
- Report all verification results to user, including successful checks
