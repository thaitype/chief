---
name: chief-upgrade
description: Upgrade the Chief framework to a specific version. Clones the target version, diffs and merges AGENTS.md with user approval. Detects a v4-or-earlier install and explains the v5 breaking change before proceeding. Use when the user wants to upgrade the framework (e.g. "/chief-upgrade" or "/chief-upgrade canary").
---

Upgrade the Chief framework to the version specified in the arguments.

## Arguments

The first argument is the target version (branch or tag). Optional.

- No argument → upgrade to the latest stable release (highest semver tag). Find it by running
  `git ls-remote --tags https://github.com/thaitype/chief.git`, strip `refs/tags/`, ignore
  `^{}` entries, and pick the highest semver version.
- `canary` → latest canary branch (active development, unreleased)
- `v5.0.0`, etc. → specific tagged version

## Steps

### 0. Detect a pre-v5 install

Check for `.agents/agents/chief-agent.md`. If it exists, this project is on **v4 or earlier**,
and the target is v5+. This is a **major breaking upgrade**, not a routine refresh — stop and
explain to the user before touching anything:

- `.agents/agents/` (chief-agent, builder-agent, tester-agent, answer-verifier-agent) is
  **removed entirely** in v5. There is nothing to migrate it to — `/chief-build` and
  `/chief-test` replace `builder-agent`/`tester-agent` as skills, not agent files; the other two
  are gone outright (see `docs/design/v5-ai-workflow.md`).
- `.chief/milestone-N/` (goal, contract, `_plan/_todo.md`, task specs) is **not migrated**. v5
  uses `.chief/story-N/` with a different shape (ticket files instead of a todo list). Any
  story/milestone in flight should be finished on a pinned v4 checkout
  (`npx skills@latest add thaitype/chief#v4.0.0` or the `release/v4` branch) — starting a new
  one after upgrading will use the v5 shape automatically via `/chief-plan`.
- Old `.chief/milestone-N/` directories are left on disk untouched (upgrade never deletes local
  content) but nothing in v5 reads them anymore.

Ask the user to confirm they understand this is a one-way jump before proceeding. If they'd
rather stay on v4, stop here and point them at pinning `#v4.0.0` / `release/v4` instead.

If `.agents/agents/chief-agent.md` is absent, this is either a fresh v5 install (use
`/chief-install` instead — stop and say so) or an already-on-v5 project doing a routine
refresh; continue to step 1.

### 1. Clone target version

```bash
git clone --depth 1 --branch <version> https://github.com/thaitype/chief.git .chief-agent-tmp
```

### 2. Diff AGENTS.md

```bash
diff AGENTS.md .chief-agent-tmp/template/AGENTS.md
```

Show the diff to the user. Explain:
- The **Project Rules** section (or, in the lazy-install convention, everything outside the
  `<!-- chief-framework:begin/end -->` markers) is user-owned — NEVER overwrite it.
- Everything else is framework content that may need updating.

If coming from a pre-v4 layout, also note that `.agents/agents/` and any `.claude/agents/` /
`.github/agents/` symlinks/copies pointing at it should be removed — they no longer serve a
purpose. Confirm with the user before deleting anything (removal, unlike everything else this
skill does, is destructive).

### 3. Wait for user approval

Ask the user to review. They may approve all, cancel, or ask for more detail.

### 4. Merge AGENTS.md

Use this priority order:

1. **If the user's `AGENTS.md` contains `<!-- chief-framework:begin -->` /
   `<!-- chief-framework:end -->` markers**: replace everything between the markers with
   `.chief-agent-tmp/template/AGENTS.md`'s content. Keep everything outside the markers exactly
   as-is.
2. **Else if the user's `AGENTS.md` has a `## Project Rules` section** (legacy layout): treat
   everything from `## Project Rules` to the next `---` as user-owned; replace everything below
   it with the new framework content. Keep Project Rules exactly as-is.
3. **Else** (no markers, no Project Rules section): treat the whole file as framework content
   and overwrite from the template.

Show the merged result and get confirmation before writing.

`.chief/` (project.md, stories, rules) is **never** touched by upgrade — it is user state, even
when empty.

### 5. Clean up stale pre-v5 artifacts (only if the user confirmed removal in step 2)

```bash
rm -rf .agents .claude/agents .github/agents
```

Only run this if coming from a pre-v5 install and the user explicitly approved it. Never run it
unprompted — a user might have local-only files under `.agents/agents/` that aren't part of the
framework roster.

### 6. Verify

Check `AGENTS.md` merged correctly and (for Claude Code) `CLAUDE.md` still resolves.

### 7. Clean up

```bash
rm -rf .chief-agent-tmp
```

### 8. Summary

Report what was changed, what was skipped, and any manual steps remaining. If this was a v4→v5
jump, remind the user: any story in flight should finish on the pinned v4 checkout; new work
started with `/chief-plan` from here on uses the v5 shape.

## Important rules

- ALL temporary files MUST be inside `.chief-agent-tmp/`. NEVER write to `/tmp`, session dirs,
  home dirs, or any other location outside the repo.
- NEVER apply changes without user approval.
- NEVER overwrite user content in `.chief/` — stories, goals, contracts, tickets, reports.
- NEVER remove local-only files without explicit confirmation for that specific removal (step 5
  is the one exception this skill ever proposes, and only after explaining why).
- NEVER summarize diffs from memory — always use actual diff output.
- Always clean up `.chief-agent-tmp` even if the upgrade is cancelled.
- A v4→v5 jump is a **major, one-way** upgrade — always detect and explain it (step 0) before
  doing anything else. Never silently treat it as a routine refresh.
