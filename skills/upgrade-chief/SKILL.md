---
name: upgrade-chief
description: Upgrade the Chief Agent Framework to a specific version. Uses upgrade.sh as the primary method, falls back to manual if script fails. Use when the user wants to upgrade the framework (e.g. "/upgrade-chief" or "/upgrade-chief canary").
---

Upgrade the Chief Agent Framework to the version specified in the arguments.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → upgrade to the latest stable release (highest semver tag). Find it by running `git ls-remote --tags https://github.com/thaitype/chief-agent-framework.git`, strip `refs/tags/`, ignore `^{}` entries, and pick the highest semver version.
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
git clone --depth 1 --branch <version> https://github.com/thaitype/chief-agent-framework.git .chief-agent-tmp
```

### 2. Run upgrade.sh --plan

```bash
bash .chief-agent-tmp/scripts/upgrade.sh --plan --agent <agent> --mode <mode>
```

Show the full output to the user. This is the upgrade plan.

### 3. Wait for user approval

Ask the user to review. They may:
- Approve all
- Cancel
- Ask for more detail on a specific file

### 4. Run upgrade.sh (apply)

```bash
bash .chief-agent-tmp/scripts/upgrade.sh --agent <agent> --mode <mode>
```

If this **succeeds**, skip to step 6.

If this **fails**, proceed to step 5.

### 5. Manual fallback (if upgrade.sh fails)

Perform the upgrade manually, same as install-chief fallback pattern:

1. **Overwrite agent files** — For each `.chief-agent-tmp/template/.agents/agents/*.md`:
   - Extract current `model:` value from the local file
   - Copy template file over local file
   - Replace `${thinking_model}` and `${coding_model}` with extracted model value
   - For new agent files (no local equivalent): copy and handle model placeholders

2. **Overwrite skills** — For each `.chief-agent-tmp/template/.agents/skills/*/`:
   - Remove local skill directory
   - Copy template skill directory

3. **Remove deleted files** — If a local agent/skill has no template equivalent:
   - Remove it

4. **Update integration files** based on agent and mode:

   **claude-code link:**
   ```bash
   for f in .agents/agents/*.md; do ln -sf "../../$f" ".claude/agents/$(basename "$f")"; done
   for d in .agents/skills/*/; do ln -sfn "../../$d" ".claude/skills/$(basename "$d")"; done
   ```

   **claude-code copy:**
   ```bash
   cp .agents/agents/*.md .claude/agents/
   cp -r .agents/skills/* .claude/skills/
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

5. **Model placeholders** — If any file still has `${thinking_model}` or `${coding_model}`:
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
- NEVER remove local-only files unless the user explicitly requests removal
- NEVER summarize diffs from memory — always use actual diff output (from upgrade.sh or manual commands)
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled
