---
name: chief-autopilot
description: Run the story's ticket frontier autonomously via /chief-build. Requires the goal and contract to exist. Creates/updates tickets as needed, works the frontier, and repeats until the story is done. Auto mode makes all decisions autonomously; safe mode stops on ambiguity. Use "/chief-autopilot" for auto or "/chief-autopilot safe" for safe mode.
---

Run the story's ticket frontier autonomously.

**Storage location:** `.chief/` is the default. If `.chief.config.md` exists at the repo
root, resolve `storage-root:` from it first and use that path everywhere below instead.

## Arguments

- No argument or `auto` → **auto mode** (default). You make all decisions, never stop for human
  input.
- `safe` → **safe mode**. Stop when ambiguity requires a design decision.

## Prerequisite Check

Before doing anything:

1. Identify the active story directory under `.chief/`.
2. Check that `_goal/` has at least one non-empty file.
3. Check that `_contract/` has at least one non-empty file.

If either is missing → **STOP**. Tell the user:
> "A goal and contract are required for autopilot. Run `/chief-plan` first."

Do NOT proceed.

## Entry Confirmation

Present the current goal and contract to the user in a brief summary (file names + 1-line
description each).

Ask one question:
> "Goal and contract look correct? Proceed with full automation, or use `/chief-plan` to revise
> first?"

If the user says revise → stop.
If the user confirms → proceed.

## Execution Loop

### 1. Compute or extend the ticket frontier

Scan `.chief/story-N/_tickets/` for `Type: implementation` tickets. If none exist yet, run
`/chief-plan` Phase 3 to create the first batch (do NOT wait for approval on this — that's
autopilot). If the frontier (open, unblocked) is empty but the goal/contract aren't yet
satisfied, run Phase 3 again for the next batch.

### 2. Delegate to `/chief-build`

For each ticket in the frontier:
- Set `Status: claimed`.
- Invoke `/chief-build <ticket-id>`, spawned as its own subagent (isolated context per ticket —
  don't run it inline).
- Wait for completion.
- Set `Status: resolved` when done.

### 3. Handle blockers and ambiguity

**Auto mode:**
- If `/chief-build` reports a blocker or ambiguity → you pick the best option and continue.
- Document the decision in the batch report (see below).

**Safe mode:**
- If `/chief-build` reports a blocker or ambiguity → **STOP** and present the issue to the user
  with options.
- Wait for user decision, then continue.

### 4. Repeat

After working the current frontier:
- If the goal isn't fully met, or the implementation doesn't yet satisfy the contract → go back
  to step 1.
- If both are satisfied → write the final batch report and stop.

## Batch Report

After each round (or when stopping), write a report to:

`.chief/story-N/_report/autopilot-run-batch-<N>.md`

Where `<N>` is the next available number (1, 2, 3...).

```md
# Autopilot Run Batch <N>

## Mode
auto | safe

## Summary
What was accomplished in this batch.

## Tickets Completed
- <id>: ...
- <id>: ...

## Decisions Made (auto mode only)
For each ambiguity encountered:
- **Issue:** what was ambiguous
- **Options:** what choices existed
- **Chosen:** which option was picked
- **Reason:** why

## Remaining
Tickets not yet resolved, and why (blocked / not yet created).

## User Action Needed
Items that require human decision or manual intervention.
```

## Rules

- NEVER start without a goal and contract existing.
- NEVER skip the entry confirmation.
- In auto mode, NEVER stop for human input — make decisions and document them.
- In safe mode, ALWAYS stop on ambiguity — never guess.
- Follow the rules hierarchy: `AGENTS.md` > `.chief/_rules` > story goal/contract.
- `/chief-build` handles all implementation. This skill NEVER writes code directly.
- `/chief-test` is NOT used unless the user explicitly requests it.
- Story completion requires BOTH the goal being met AND the contract being satisfied — this
  check is Chief's own; nothing in matt's skillset provides an equivalent, so don't drop it
  while adopting `/chief-build`.
