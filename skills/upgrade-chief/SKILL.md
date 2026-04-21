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

### 2. Diff current files vs target version

**CRITICAL: The framework stores installable files under `template/`. Always compare `.chief-agent-tmp/template/<path>` → `<path>` in the project. NEVER compare against the framework repo root.**

Compare these paths between the current project and `.chief-agent-tmp/template/`:

- `AGENTS.md` (or `CLAUDE.md` if `AGENTS.md` does not exist)
- `.agents/agents/*.md`
- `.agents/skills/*/`
- `.chief/MANUAL.md`
- `.chief/project.md` (template only — compare structure, not user content)
- `.chief/_rules/` (directory structure, not user content)
- `.chief/_template/`

For each file, run `diff` or `git diff --no-index` and capture the output. You MUST use actual diff output to build the upgrade plan — do not summarize from memory or file names alone.

**Separating model field from content:** When diffing `.agents/agents/*.md` files, the `model:` field in YAML frontmatter is ALWAYS user-configured. To classify correctly:

1. Strip the `model:` line from both local and target files before diffing content.
2. If content (everything except `model:`) differs → classify based on content diff only.
3. The `model:` value is NEVER a reason to classify a file as a conflict.
4. When applying a framework update to an agent file, ALWAYS preserve the user's current `model:` value.

### 3. Categorize each change

For every file that differs, classify it:

| Category | Description |
|---|---|
| **Framework update** | File exists in both, target version changed (ignoring `model:` field). Safe to overwrite (preserving user's `model:` value). |
| **New file** | File exists in target but not in current project. Safe to add. |
| **User content** | Files that contain user-written content mixed with framework content. Needs review. |
| **Structure change** | File type changed (e.g. real file became symlink, directory renamed). Needs review. |
| **Local-only file** | File exists in current but not in target. **Keep by default.** Only remove if user explicitly requests removal. |

**Classification rules:**

- `.agents/agents/*.md` and `.agents/skills/**` are ALWAYS **framework update**, never conflicts. The user chose to upgrade — these files are framework-owned. Recommend overwrite.
- `AGENTS.md` is **user content** because it contains the Project Rules section which the user wrote. Show diff, let user review.
- `.chief/project.md` is **user content**. Show diff, let user review.
- `.chief/_rules/`, `.chief/_template/` are **framework update** (structure/scaffolding).
- `.chief/milestone-*/**` is NEVER touched by upgrade. Skip entirely.
- A `model:` field difference alone is NEVER a reason to change category — it is expected and always preserved.

### 4. Present the upgrade plan

You MUST display the full upgrade plan text inline in your response. Do NOT ask "how would you like to proceed" or prompt for approval before showing the plan.

**Default recommendation:** All `.agents/agents/*.md` and `.agents/skills/**` files should be recommended to **overwrite** since the user explicitly chose to upgrade. The user invoked upgrade — they expect updates. If a user rejects a specific file, they are responsible for merging manually.

Format the plan clearly, showing **actual diff output** for every changed file:

```
## Upgrade Plan: <current> → <target>

### 1. Agent definitions (.agents/agents/)

**<file>** — ✅ Overwrite (recommended)
> model: preserved as `<user's current model>`

\```diff
<actual diff output with model: lines excluded>
\```

### 2. Skills (.agents/skills/)

**<file>** — ✅ Overwrite (recommended)

\```diff
<actual diff output>
\```

### 3. New files

- <file> — <description>

### 4. Project files (AGENTS.md, .chief/)

**<file>** — ⚠️ Review required (contains user content)

\```diff
<actual diff output>
\```

### 5. Structure changes

- <file> — <description of change>

### 6. Local-only files (kept by default)

- <file> — exists locally but not in target version
```

Rules for the plan:
- If a section has no entries, omit it.
- MUST show actual diff output for every changed file — not prose summaries.
- Agent and skill files MUST default to "Overwrite (recommended)".
- Files with user content (AGENTS.md Project Rules section, `.chief/project.md`, milestone files) MUST default to "Review required".
- For agent files, always note that the user's `model:` value will be preserved.

### 5. Wait for user approval

Ask the user to review the plan. Do NOT apply any changes until the user explicitly approves.

The user may:
- Approve all changes
- Approve some and reject others
- Ask for more details about a specific change
- Cancel the upgrade

### 6. Apply approved changes

For each approved change:
- **Framework update**: overwrite the file from target version. For `.agents/agents/*.md` files, preserve the user's current `model:` value — do not replace it with the template placeholder.
- **New file**: copy from target version
- **Conflict**: show a diff and let the user decide (overwrite, skip, or merge manually)
- **Structure change**: apply the structural change (e.g. create symlinks)
- **Local-only file**: keep as-is (default). Only delete if the user explicitly requests removal.

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

## Important rules

- ALL temporary files MUST be inside `.chief-agent-tmp/`. NEVER write to `/tmp`, session dirs, home dirs, or any other location outside the repo.
- NEVER apply changes without user approval
- NEVER overwrite user content in `.chief/` milestones (goals, contracts, plans, reports)
- NEVER remove local-only files unless the user explicitly requests removal. Local-only files are kept by default.
- NEVER ask for approval before showing the upgrade plan. Show the plan first, then ask.
- NEVER summarize diffs from memory — always run actual diff commands against `template/`
- If uncertain whether a file was user-modified, classify it as a conflict
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled
