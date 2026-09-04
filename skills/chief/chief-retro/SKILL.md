---
name: chief-retro
description: Run a retrospective on the current story or latest round. Checks goal/contract coverage, summarizes planned vs delivered, and proposes rule updates. Use "/chief-retro" after completing a round or a story.
---

Run a retrospective on the current story.

**Storage location:** `.chief/` is the default. If `.chief.config.md` exists at the repo
root, resolve `storage-root:` from it first and use that path everywhere below instead.

## Scope Detection

Auto-detect the scope:

1. Scan `.chief/story-N/_tickets/` for `Type: implementation` tickets.
2. If ALL of them are `Status: resolved` (and no ticket is still blocked awaiting a future
   `/chief-plan` round) → **story retro**.
3. If some remain `open`/`claimed`, or the goal/contract aren't yet satisfied → **round retro**
   (covers only the latest completed round of tickets — since `/chief-loop`/`/chief-autopilot`
   dropped the fixed-size batch, a "round" is whatever set of tickets was worked before this
   retro was invoked, inferred from the most recent `_report/` files' timestamps/content).

## Input Sources

### Round retro
- The most recent `_report/ticket-<id>-report.md` files and/or
  `_report/autopilot-run-batch-<N>.md` (whichever the loop/autopilot run produced)
- `_tickets/` (resolved vs open vs blocked)
- `_goal/` and `_contract/` files
- `git log` for commits since the previous round's report (or story start)

### Story retro
- ALL `_report/` files (ticket reports, batch reports, investigations)
- `_tickets/` (full history)
- `_goal/` and `_contract/` files
- `git log` for the entire story

## Report Sections

Write the report with these sections:

```md
# Retro: story-N — <round N | story>

## Coverage Check

For each goal and contract file, check whether the work done satisfies it:

| File | Status | Notes |
|------|--------|-------|
| _goal/goal.md | ✅ Satisfied / ⚠️ Partial / ❌ Missing | what's done or missing |
| _contract/contract.md | ✅ / ⚠️ / ❌ | ... |

## Planned vs Delivered

- What the ticket breakdown called for
- What was actually completed (resolved tickets)
- What was skipped, split, or changed mid-execution

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
- Uncovered goal/contract areas that need another round of tickets
- Decisions to promote to permanent rules
- Manual steps that automation couldn't handle
```

## Output File

- Round retro → `.chief/story-N/_report/retro-round-<N>.md`
- Story retro → `.chief/story-N/_report/retro-story.md`

Where `<N>` matches the round being reviewed (infer it from existing `retro-round-*.md` files —
next available number).

## After Report

Present the proposed rule updates to the user. Ask:
> "Want me to apply any of these rule proposals?"

- User picks which ones to apply.
- For each approved proposal, create or update the file in `.chief/_rules/`.
- For rejected proposals, leave them in the report only.

## Rules

- NEVER skip the coverage check — this is the primary value of the retro.
- NEVER auto-apply rule proposals — always ask first.
- NEVER modify the goal, contract, or tickets — retro is read-only on those. Only `_rules/` can
  be updated.
- Use actual git log and file content — do not summarize from memory.
- Follow the rules hierarchy: `AGENTS.md` > `.chief/_rules` > story goal.
