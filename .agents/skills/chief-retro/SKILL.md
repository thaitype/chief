---
name: chief-retro
description: Run a retrospective on the current milestone or latest batch. Checks goal/contract coverage, summarizes planned vs delivered, and proposes rule updates. Use "/chief-retro" after completing a batch or milestone.
---

Run a retrospective on the current milestone.

## Scope Detection

Auto-detect the scope:

1. Read `_plan/_todo.md` in the active milestone.
2. If ALL tasks are marked `[x]` → **milestone retro**.
3. If some tasks remain → **batch retro** (covers only the latest completed batch).

## Input Sources

### Batch retro
- Latest `_report/autopilot-run-batch-<N>.md`
- `_plan/_todo.md` (completed vs remaining)
- `_goal/` and `_contract/` files
- `git log` for commits since the previous batch report (or milestone start)

### Milestone retro
- ALL `_report/` files (batch reports, task outputs, etc.)
- `_plan/_todo.md` (full history)
- `_goal/` and `_contract/` files
- `git log` for the entire milestone

## Report Sections

Write the report with these sections:

```md
# Retro: <milestone> — <batch N | milestone>

## Coverage Check

For each goal and contract file, check whether the work done satisfies it:

| File | Status | Notes |
|------|--------|-------|
| _goal/xxx.md | ✅ Satisfied / ⚠️ Partial / ❌ Missing | what's done or missing |
| _contract/xxx.md | ✅ / ⚠️ / ❌ | ... |

## Planned vs Delivered

- What was in the TODO
- What was actually completed
- What was skipped or changed mid-execution

## Blockers Hit

- Issues encountered during execution
- How they were resolved (or not)

## Lessons Learned

- Patterns observed (good and bad)
- Recurring problems
- Surprises or unexpected outcomes
- What worked well and should be repeated

## Proposed Rule Updates

For each proposal:
- **What:** the rule to add or change
- **Where:** which file in `.chief/_rules/` (e.g. `_standard/auth.md`, `_verification/tests.md`)
- **Why:** what happened that motivates this rule
- **Suggestion:** recommended for the user

## User Action Needed

Items requiring human decision:
- Uncovered goals or contracts that need another batch
- Decisions to promote to permanent rules
- Manual steps that automation couldn't handle
```

## Output File

- Batch retro → `.chief/<milestone>/_report/retro-batch-<N>.md`
- Milestone retro → `.chief/<milestone>/_report/retro-milestone.md`

Where `<N>` matches the batch number being reviewed.

## After Report

Present the proposed rule updates to the user. Ask:
> "Want me to apply any of these rule proposals?"

- User picks which ones to apply.
- For each approved proposal, create or update the file in `.chief/_rules/`.
- For rejected proposals, leave them in the report only.

## Rules

- NEVER skip the coverage check — this is the primary value of the retro.
- NEVER auto-apply rule proposals — always ask first.
- NEVER modify goals, contracts, or plans — retro is read-only on those. Only `_rules/` can be updated.
- Use actual git log and file content — do not summarize from memory.
- Follow the rules hierarchy: AGENTS.md > .chief/_rules > milestone goals.
