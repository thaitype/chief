---
name: chief-install
description: Install the Chief framework into the current project. Installs subagents and AGENTS.md only — `.chief/` is created lazily by chief-agent at runtime. Use when the user wants to set up the framework (e.g. "/chief-install" or "/chief-install canary").
---

Install the Chief framework into the current project.

This is a **lazy install**: only subagents and `AGENTS.md` are placed at install time. `.chief/` (project.md, milestones, rules) is created on demand by chief-agent — run `/chief-init` to bootstrap project context, or just start with `/chief-plan`.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → install the latest stable release (highest semver tag). Find it by running `git ls-remote --tags https://github.com/thaitype/chief.git`, strip `refs/tags/`, ignore `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v1.0.0`, `v2.0.0`, etc. → specific tagged version

## Steps

### 1. Check for existing installation

Check if the Chief is already installed by looking for these signals:

1. `.agents/agents/chief-agent.md` exists
2. `AGENTS.md` at root contains the keyword "Chief" or "chief-agent" (check file content, not just existence — these files may exist from other setups)

If **any** of these match → the framework is likely already installed. Warn the user and suggest upgrading instead. Show them:
```
npx skills@latest add thaitype/chief --skill chief-upgrade
/chief-upgrade
```
Do NOT proceed unless the user explicitly confirms they want a fresh install.

If **none** match → proceed.

### 2. Ask coding agent and install mode

Ask the user:

1. **Which coding agent?** — Supported agents: `claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`
2. **Install mode?** (relevant for `claude-code` and `copilot`)
   - **link** (recommended) — symlinks from agent-specific directory to `.agents/`
   - **copy** — copies files instead of symlinking
   - On Windows, link mode requires Developer Mode enabled and `git config --global core.symlinks true`. If unavailable, suggest copy mode.
   - For all other agents, mode does not affect behavior since they read `AGENTS.md` and `.agents/` directly

### 3. Clone and run setup script

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief.git .chief-agent-tmp
bash .chief-agent-tmp/scripts/setup.sh --agent <agent> --mode <mode>
```

The script installs:
- `.agents/agents/*.md` — subagent definitions (chief, builder, tester, review-plan)
- `AGENTS.md` — framework rules (Fresh write if absent; appended in a `<!-- chief-framework:begin -->` block if `AGENTS.md` already exists)
- Agent-specific integration files (`.claude/agents/`, `.github/agents/`) for `claude-code` / `copilot`

It does **NOT** create `.chief/`. That is intentional.

If the setup script **fails completely** (non-zero exit code or crashes), skip to step 3b for full manual install. Do NOT run `rm -rf .chief-agent-tmp` yet — it's needed for manual steps.

If the setup script succeeds, proceed to step 4.

### 3b. Full manual install (fallback if setup script fails)

If the setup script failed, perform the entire install manually:

```bash
# Subagent definitions (canonical)
cp -r .chief-agent-tmp/template/.agents .agents
```

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

For `claude-code` only, set up Claude Code integration:

Link mode:
```bash
ln -s AGENTS.md CLAUDE.md
mkdir -p .claude/agents
for f in .agents/agents/*.md; do ln -s "../../$f" ".claude/agents/$(basename "$f")"; done
```

Copy mode:
```bash
cp AGENTS.md CLAUDE.md
mkdir -p .claude/agents
cp .agents/agents/*.md .claude/agents/
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

For non-`claude-code` agents, ask the user for model names:
1. **Thinking Model** (for chief-agent, e.g. `o3`, `gemini-2.5-pro`)
2. **Coding Model** (for builder/tester/review-plan, e.g. `gpt-4.1`, `gemini-2.5-flash`)

Replace `${thinking_model}` with the Thinking Model in chief-agent, and `${coding_model}` with the Coding Model in all other agent files. For `claude-code`, auto-replace with `opus` and `sonnet` (no prompt needed). For `copilot`, update files in `.github/agents/`. For other agents, update files in `.agents/agents/`.

Skip any file that already exists (warn the user).

### 4. Verify installation

After the setup script or manual install completes, verify:

1. **Subagent files exist:**
   - `.agents/agents/chief-agent.md`
   - `.agents/agents/builder-agent.md`
   - `.agents/agents/tester-agent.md`
   - `.agents/agents/review-plan-agent.md`
   - `.agents/agents/answer-verifier-agent.md`

2. **AGENTS.md exists** and contains chief framework content (either the whole file or a `<!-- chief-framework:begin -->` block).

3. **Claude Code only** (if agent is `claude-code`):
   - `CLAUDE.md` exists (symlink or copy depending on mode)
   - `.claude/agents/` contains entries for all 5 agents
   - If link mode: verify symlinks resolve correctly

4. **Copilot only** (if agent is `copilot`):
   - `.github/agents/` contains entries for all 5 agents (symlinks or copies depending on mode)
   - If link mode: verify symlinks resolve correctly
   - Model values have been replaced if the user provided model names

`.chief/` is **not** expected to exist after install — do not flag its absence.

### 5. Fix issues (fallback)

If any verification check fails, fix it manually:

- **Missing subagent file** → copy from `.chief-agent-tmp/template/.agents/agents/` if it still exists, otherwise clone again and copy the specific file
- **Missing AGENTS.md** → re-run the Fresh-or-Append snippet from 3b
- **Missing CLAUDE.md** → create symlink (`ln -s AGENTS.md CLAUDE.md`) or copy depending on mode
- **Missing .claude/ symlinks** → create them individually:
  ```bash
  mkdir -p .claude/agents
  ln -s ../../.agents/agents/<file>.md .claude/agents/<file>.md
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

1. Run `/chief-init` to bootstrap `.chief/project.md` with your tech stack and dev commands
2. Review `AGENTS.md` and customize if needed
3. Start planning: `/chief-plan` (or ask chief-agent directly)

`.chief/` and its subfolders will be created automatically as you work — milestone folders, rule subfolders, and reports are all written on first need.

## Important rules

- NEVER overwrite existing files without explicit user approval
- If `AGENTS.md` already exists and contains content, append the chief block; do NOT overwrite
- If the framework is already installed, suggest `/chief-upgrade` instead
- Always clean up `.chief-agent-tmp` even if the install is cancelled or fails
- If the setup script fails, attempt manual fixes before giving up
- Do NOT create `.chief/` at install — that is now lazy
- Report all verification results to the user — even successful ones
