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

### 1. Clone the target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
```

### 2. Diff current files vs target version

Compare these paths between the current project and `.chief-agent-tmp/`:

- `AGENT.md` (or `CLAUDE.md` if `AGENT.md` does not exist)
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

### 7. Update symlinks

After applying changes, check if new agents or skills were added in `.agents/`. If the user has `.claude/` with symlinks, create symlinks for any new files:

```bash
ln -s ../../.agents/agents/<new-agent>.md .claude/agents/<new-agent>.md
ln -s ../../.agents/skills/<new-skill> .claude/skills/<new-skill>
```

Skip symlinks that already exist.

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
