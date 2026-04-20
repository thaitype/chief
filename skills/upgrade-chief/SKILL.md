---
name: upgrade-chief
description: Upgrade the Chief Agent Framework to a specific version. Compares current files against the target version, creates an upgrade plan for review, and applies changes on approval. Use when the user wants to upgrade the framework (e.g. "/upgrade-chief" or "/upgrade-chief canary").
---

Upgrade the Chief Agent Framework to the version specified in the arguments.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → upgrade to the latest stable release (highest semver tag). Find it by running `git ls-remote --tags https://github.com/thaitype/chief-agent-framework.git`, strip `refs/tags/`, ignore `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v1.0.0`, `v2.0.0`, etc. → specific tagged version

## Steps

### 0. Detect coding agent and install mode

Before cloning, detect which coding agent the user has set up:

1. Check if `.claude/agents/` exists → **Claude Code**
2. Check if `.github/agents/` exists with `.agent.md` files → **Copilot**
3. If only `.agents/` exists (no coding-agent-specific directory) → **OpenCode** (or no coding agent setup)

For coding agents that use their own directory (e.g. Claude Code with `.claude/`), detect install mode:

1. Check if any file in the coding-agent-specific directory is a symlink → current mode is **link**
2. If files are regular files → current mode is **copy**
3. If no coding-agent-specific directory exists → no mode detected

Ask the user to confirm:
- Which coding agent they use (Claude Code, Copilot, OpenCode, or other)
- Which install mode they want: **link** (recommended) or **copy**

Default to the detected coding agent and mode. If no mode is detected, suggest **link**. Copilot always uses **copy** mode. OpenCode reads `.agents/` directly and needs no install mode.

### 1. Clone the target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
```

### 2. Diff current files vs target version

Compare these paths between the current project and `.chief-agent-tmp/`:

- `AGENTS.md` (or `CLAUDE.md` if `AGENTS.md` does not exist)
- `.agents/agents/*.md`
- `.agents/skills/*/`
- `.chief/MANUAL.md`
- `.chief/project.md` (template only — compare structure, not user content)
- `.chief/_rules/` (directory structure, not user content)
- `.chief/_template/`

### 3. Categorize each change

For every file that differs, classify it:

| Category | Description |
|---|---|
| **Framework update** | File exists in both, only target version changed. Safe to overwrite. |
| **New file** | File exists in target but not in current project. Safe to add. |
| **User-modified conflict** | File exists in both, and the user has modified it from the original. Needs review. |
| **Structure change** | File type changed (e.g. real file became symlink, directory renamed). Needs review. |
| **Removal** | File exists in current but not in target. Check if user depends on it. |

To detect user modifications: compare the current file against both the original installed version (if detectable from git history) and the target version. If uncertain, classify as conflict.

### 4. Present the upgrade plan

Format the plan clearly:

```
## Upgrade Plan: <current> → <target>

### Framework updates (safe to overwrite)
- <file> — <what changed>

### New files
- <file> — <description>

### Conflicts (needs review)
- <file> — you modified this file, target version also changed

### Structure changes
- <file> — <description of change>

### Removals
- <file> — exists locally but not in target version
```

If a section has no entries, omit it.

### 5. Wait for user approval

Ask the user to review the plan. Do NOT apply any changes until the user explicitly approves.

The user may:
- Approve all changes
- Approve some and reject others
- Ask for more details about a specific change
- Cancel the upgrade

### 6. Apply approved changes

For each approved change:
- **Framework update**: overwrite the file from target version
- **New file**: copy from target version
- **Conflict**: show a diff and let the user decide (overwrite, skip, or merge manually)
- **Structure change**: apply the structural change (e.g. create symlinks)
- **Removal**: delete the file (only if user approves)

### 7. Update coding agent integration

After applying changes, check if new agents or skills were added in `.agents/`. Based on the coding agent detected in step 0:

**Claude Code** — update `.claude/` using the chosen mode:

Link mode:
```bash
ln -s ../../.agents/agents/<new-agent>.md .claude/agents/<new-agent>.md
ln -s ../../.agents/skills/<new-skill> .claude/skills/<new-skill>
```

Copy mode:
```bash
cp .agents/agents/<new-agent>.md .claude/agents/<new-agent>.md
cp -r .agents/skills/<new-skill> .claude/skills/<new-skill>
```

**Copilot** — copy agents to `.github/agents/` with `.agent.md` suffix:

```bash
mkdir -p .github/agents
for f in .agents/agents/<new-agent>.md; do
  name="$(basename "$f" .md)"
  cp "$f" ".github/agents/${name}.agent.md"
done
```

Preserve the user's custom model values in existing `.github/agents/` files. Only update content, not the `model:` field, unless the user explicitly approves.

**OpenCode** — no action needed, it reads `.agents/` directly.

Skip entries that already exist.

Also handle the coding-agent-specific rules file at root using the chosen mode:
- For Claude Code: `CLAUDE.md` should be a symlink to `AGENTS.md` (link mode) or a copy (copy mode)
- For Copilot: `.github/agents/*.agent.md` should be copies from `.agents/agents/*.md`
- If the current state doesn't match the chosen mode, include this in the upgrade plan as a structure change

### 8. Clean up

```bash
rm -rf .chief-agent-tmp
```

### 9. Summary

Report what was changed, what was skipped, and any manual steps the user still needs to take.

## Important rules

- NEVER apply changes without user approval
- NEVER overwrite user content in `.chief/` milestones (goals, contracts, plans, reports)
- NEVER delete user files without explicit approval
- If uncertain whether a file was user-modified, classify it as a conflict
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled
