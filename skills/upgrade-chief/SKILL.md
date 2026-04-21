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

### 0. Detect current profile, coding agent, and upgrade type

#### 0a. Detect current profile

Check the project directory to determine which profile is installed:

- If `.chief/` directory exists AND `.agents/` directory exists → current profile is **full**
- If only `AGENTS.md` exists (no `.chief/`, no `.agents/`) → current profile is **lite**
- If the state is ambiguous (e.g. `.agents/` exists but `.chief/` does not) → ask the user which profile they intended to install

#### 0b. Ask for upgrade type

Ask the user which type of upgrade they want:

- **`version`** (default) — upgrade to a newer version of the same profile
- **`profile`** — upgrade from lite to full (additive, adds the full framework structure)

If the user is already on **full** and requests a **profile** upgrade, inform them they are already on the full profile. No downgrade from full to lite is supported.

#### 0c. Detect coding agent and install mode

Before cloning, detect which coding agent the user has set up by checking directories:

1. Check if `.claude/agents/` exists → suggest **Claude Code**
2. Check if `.github/agents/` exists with agent files → suggest **Copilot**
3. If only `.agents/` exists (no coding-agent-specific directory) → suggest **OpenCode** (or unknown agent)

For coding agents that use their own directory, detect install mode:

1. Check if any file in the coding-agent-specific directory is a symlink → current mode is **link**
2. If files are regular files → current mode is **copy**
3. If no coding-agent-specific directory exists → no mode detected

Always ask the user to confirm:
- Which coding agent they use — Supported agents: `claude-code`, `opencode`, `codex`, `cursor`, `copilot`, `gemini-cli`, `amp`, `windsurf`, `kiro`, `aider`
- Which install mode they want: **link** (recommended) or **copy**

Default to the detected coding agent and mode. If no mode is detected, suggest **link**. On Windows, if symlinks are not available (Developer Mode disabled), suggest **copy** mode. OpenCode reads `.agents/` directly and needs no install mode.

### 1. Clone the target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
```

---

## Version upgrade (same profile)

Follow steps 2–9 below when the upgrade type is **version**.

### 2. Diff current files vs target version

Compare these paths between the current project and `.chief-agent-tmp/template/`.

Note: The framework repo stores installable files under `template/`. When comparing, map `.chief-agent-tmp/template/<path>` to `<path>` in the current project.

**Full profile** — compare against `template/AGENTS.full.md` (map to `AGENTS.md` in the project):
- `AGENTS.md` (compare against `template/AGENTS.full.md`)
- `.agents/agents/*.md`
- `.agents/skills/*/`
- `.chief/MANUAL.md`
- `.chief/project.md` (template only — compare structure, not user content)
- `.chief/_rules/` (directory structure, not user content)
- `.chief/_template/`

**Lite profile** — compare against `template/AGENTS.lite.md` (map to `AGENTS.md` in the project):
- `AGENTS.md` (compare against `template/AGENTS.lite.md`)
- Coding agent symlink or copy (e.g. `CLAUDE.md` for Claude Code)

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
## Upgrade Plan: <current> → <target> (version upgrade, <profile> profile)

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

**Copilot** — update `.github/agents/` using the chosen mode:

Link mode:
```bash
ln -s ../../.agents/agents/<new-agent>.md .github/agents/<new-agent>.md
```

Copy mode:
```bash
cp .agents/agents/<new-agent>.md .github/agents/<new-agent>.md
```

Preserve the user's custom model values in existing agent files. Only update content, not the `model:` field, unless the user explicitly approves.

**OpenCode** — no action needed, it reads `.agents/` directly.

Skip entries that already exist.

### 7b. Check model configuration (non-Claude Code only)

For non-Claude Code agents, check if agent files still contain the default `model: opus` or `model: sonnet` values (i.e., models were never customized by the user).

Determine the agent directory to check:
- **Copilot**: check `.github/agents/`
- **Other non-Claude Code agents**: check `.agents/agents/`

If any agent file still has placeholder model values (`model: ${thinking_model}` or `model: ${coding_model}`):
- For **Claude Code**: auto-replace `${thinking_model}` → `opus`, `${coding_model}` → `sonnet` (no prompt needed)
- For **other agents**: ask the user:
   1. **Thinking Model** (for chief-agent, e.g. `o3`, `gemini-2.5-pro`)
   2. **Coding Model** (for builder/tester/review-plan, e.g. `gpt-4.1`, `gemini-2.5-flash`)
   
   Replace `${thinking_model}` with the Thinking Model and `${coding_model}` with the Coding Model.

If all agent files already have real model values (no placeholders), skip this step — the user has already configured their models.

Also handle the coding-agent-specific rules file at root using the chosen mode:
- For Claude Code: `CLAUDE.md` should be a symlink to `AGENTS.md` (link mode) or a copy (copy mode)
- For Copilot: `.github/agents/*.md` should be symlinks (link mode) or copies (copy mode) from `.agents/agents/*.md`
- If the current state doesn't match the chosen mode, include this in the upgrade plan as a structure change

### 8. Clean up

```bash
rm -rf .chief-agent-tmp
```

### 9. Summary

Report what was changed, what was skipped, and any manual steps the user still needs to take.

---

## Lite → Full profile upgrade

Follow these steps when the upgrade type is **profile** and the current profile is **lite**.

### P1. Clone the target version

(Already done in step 1 above.)

### P2. Present the upgrade plan

Clearly describe what will happen:

```
## Profile Upgrade Plan: lite → full (<target> version)

### AGENTS.md
- Current AGENTS.md (lite) will be backed up as AGENTS.md.lite.bak
- Replaced with full profile version from template/AGENTS.full.md
- If you have project-specific rules in your current AGENTS.md, they will be extracted
  and migrated to .chief/project.md

### New directories and files
- .agents/           — agent definitions for chief, builder, tester, review-plan agents
- .chief/            — milestone skeleton, rules, templates, MANUAL.md, project.md
- .claude/agents/    — coding agent integration (Claude Code)  [or equivalent for other agents]
- .claude/skills/    — skill integration (Claude Code)         [or equivalent for other agents]

### Coding agent integration
- Agent files and skills will be linked/copied from .agents/ using <link|copy> mode
```

Note: Only include sections relevant to what will actually be created.

### P3. Wait for user approval

Do NOT apply any changes until the user explicitly approves.

### P4. Apply the profile upgrade

Execute these steps in order:

1. **Backup current AGENTS.md**:
   ```bash
   cp AGENTS.md AGENTS.md.lite.bak
   ```

2. **Replace AGENTS.md with full profile version**:
   ```bash
   cp .chief-agent-tmp/template/AGENTS.full.md AGENTS.md
   ```

3. **Copy `.agents/` directory from template**:
   ```bash
   cp -r .chief-agent-tmp/template/.agents .agents
   ```

4. **Copy `.chief/` directory from template**:
   ```bash
   cp -r .chief-agent-tmp/template/.chief .chief
   ```

5. **Set up coding agent integration** (same as install-chief full mode). Based on the detected coding agent:

   **Claude Code** — link mode:
   ```bash
   mkdir -p .claude/agents .claude/skills
   ln -s ../../.agents/agents/<agent>.md .claude/agents/<agent>.md
   ln -s ../../.agents/skills/<skill> .claude/skills/<skill>
   ln -s ../AGENTS.md CLAUDE.md   # if CLAUDE.md does not already exist
   ```

   **Claude Code** — copy mode:
   ```bash
   mkdir -p .claude/agents .claude/skills
   cp .agents/agents/<agent>.md .claude/agents/<agent>.md
   cp -r .agents/skills/<skill> .claude/skills/<skill>
   cp AGENTS.md CLAUDE.md   # if CLAUDE.md does not already exist
   ```

   **Copilot** — link or copy mode (same pattern as version upgrade step 7).

   **OpenCode** — no action needed.

6. **Migrate project-specific rules** (if any were detected in the lite `AGENTS.md`):
   - Show the user which rules appear to be project-specific (not framework boilerplate).
   - Append them to `.chief/project.md` under a clearly marked section.
   - Inform the user to review `.chief/project.md` after the upgrade.

### P5. Clean up

```bash
rm -rf .chief-agent-tmp
```

### P6. Summary

Report:
- What was created
- Where the old lite AGENTS.md was backed up (`AGENTS.md.lite.bak`)
- Whether project-specific rules were migrated to `.chief/project.md`
- Any manual steps the user still needs to take (e.g. configuring models in agent files)

---

## Important rules

- NEVER apply changes without user approval
- NEVER overwrite user content in `.chief/` milestones (goals, contracts, plans, reports)
- NEVER delete user files without explicit approval
- NEVER delete or discard user's custom rules without migrating them first
- No downgrade from full profile to lite profile is supported
- If uncertain whether a file was user-modified, classify it as a conflict
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled
