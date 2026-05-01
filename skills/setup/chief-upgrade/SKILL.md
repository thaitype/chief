---
name: chief-upgrade
description: Upgrade the Chief to a specific version. Uses upgrade.sh as the primary method, falls back to manual if script fails. Use when the user wants to upgrade the framework (e.g. "/chief-upgrade" or "/chief-upgrade canary").
---

Upgrade the Chief to the version specified in the arguments.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → upgrade to the latest stable release (highest semver tag). Find it by running `git ls-remote --tags https://github.com/thaitype/chief.git`, strip `refs/tags/`, ignore `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v1.0.0`, `v2.0.0`, etc. → specific tagged version

## Steps

### 0. Detect coding agent and install mode

Detect which coding agent the user has set up:

1. `.claude/agents/` exists → suggest **claude-code**
2. `.github/agents/` exists → suggest **copilot**
3. Only `.agents/` exists → suggest **opencode**

Detect install mode:

1. Any file in the agent-specific directory is a symlink → **link**
2. Files are regular files → **copy**
3. No agent-specific directory → suggest **link**

Ask the user to confirm agent and mode.

### 1. Clone target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief.git .chief-agent-tmp
```

### 2. Run upgrade.sh --plan and diff AGENTS.md

Run the upgrade script plan:
```bash
bash .chief-agent-tmp/scripts/upgrade.sh --plan --agent <agent> --mode <mode>
```

Then separately diff AGENTS.md (the script does not handle this file):
```bash
diff AGENTS.md .chief-agent-tmp/template/AGENTS.md
```

Show both outputs to the user. For AGENTS.md, explain:
- The **Project Rules** section at the top is user-owned — NEVER overwrite it.
- Everything below (Rules Hierarchy, Chief, etc.) is framework content that may need updating.

### 3. Wait for user approval

Ask the user to review. They may:
- Approve all
- Cancel
- Ask for more detail on a specific file

### 4. Run upgrade.sh (apply) and merge AGENTS.md

```bash
bash .chief-agent-tmp/scripts/upgrade.sh --agent <agent> --mode <mode>
```

Then merge AGENTS.md manually:

1. Read the user's current `AGENTS.md` — identify the **Project Rules** section (everything between `## Project Rules` and the next `---`).
2. Read `.chief-agent-tmp/template/AGENTS.md` — this is the new framework version.
3. Replace everything in the user's `AGENTS.md` **below** the Project Rules section with the new framework content from template.
4. Keep the user's Project Rules section exactly as-is.
5. Show the user the merged result and get confirmation before writing.

If the user's AGENTS.md has no `## Project Rules` section, treat the entire file as framework content and overwrite it from template.

If upgrade.sh **succeeds**, skip to step 6.

If upgrade.sh **fails**, proceed to step 5.

### 5. Manual fallback (if upgrade.sh fails)

Perform the upgrade manually, same as chief-install fallback pattern:

1. **Overwrite agent files** — For each `.chief-agent-tmp/template/.agents/agents/*.md`:
   - Extract current `model:` value from the local file
   - Copy template file over local file
   - Replace `${thinking_model}` and `${coding_model}` with extracted model value
   - For new agent files (no local equivalent): copy and handle model placeholders

2. **Update integration files** based on agent and mode:

   **claude-code link:**
   ```bash
   for f in .agents/agents/*.md; do ln -sf "../../$f" ".claude/agents/$(basename "$f")"; done
   ```

   **claude-code copy:**
   ```bash
   cp .agents/agents/*.md .claude/agents/
   ```

   **copilot link:**
   ```bash
   for f in .agents/agents/*.md; do ln -sf "../../$f" ".github/agents/$(basename "$f")"; done
   ```

   **copilot copy:**
   ```bash
   cp .agents/agents/*.md .github/agents/
   ```

   **Other agents** — no integration files needed.

3. **Model placeholders** — If any file still has `${thinking_model}` or `${coding_model}`:
   - claude-code: replace with `opus`/`sonnet`
   - Others: ask user for model names, replace

### 6. Verify

Check that all expected files exist and symlinks resolve (if link mode). Fix any issues found.

### 7. Clean up

```bash
rm -rf .chief-agent-tmp
```

### 8. Summary

Report what was changed, what was skipped, and any manual steps remaining.

## Important rules

- ALL temporary files MUST be inside `.chief-agent-tmp/`. NEVER write to `/tmp`, session dirs, home dirs, or any other location outside the repo.
- NEVER apply changes without user approval
- NEVER overwrite user content in `.chief/` milestones (goals, contracts, plans, reports)
- NEVER remove local-only files — upgrade only updates and adds, never deletes
- NEVER summarize diffs from memory — always use actual diff output (from upgrade.sh or manual commands)
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled
