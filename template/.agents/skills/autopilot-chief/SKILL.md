---
name: autopilot-chief
description: Run chief-agent in full autopilot. Requires goals and contracts to exist. Chief creates TODO, delegates to builder, and repeats until milestone is done. Auto mode makes all decisions autonomously; safe mode stops on ambiguity. Use "/autopilot-chief" for auto or "/autopilot-chief safe" for safe mode.
---

Run the chief-agent autonomously on the current milestone.

## Arguments

- No argument or `auto` → **auto mode** (default). Chief makes all decisions, never stops for human input.
- `safe` → **safe mode**. Chief stops when ambiguity requires a design decision.

## Prerequisite Check

Before doing anything:

1. Identify the active milestone directory under `.chief/`.
2. Check that `_goal/` has at least one non-empty file.
3. Check that `_contract/` has at least one non-empty file.

If either is missing → **STOP**. Tell the user:
> "Goals and contracts are required for autopilot. Run `/plan-milestone` first."

Do NOT proceed.

## Entry Confirmation

Present the current goals and contracts to the user in a brief summary (file names + 1-line description each).

Ask one question:
> "Goals and contracts look correct? Proceed with full automation, or use `/plan-milestone` to revise first?"

If the user says revise → stop.
If the user confirms → proceed.

## Execution Loop

### 1. Create or update TODO

Read existing `_plan/_todo.md` if present. Create the next batch of 3–5 tasks based on goals, contracts, and what's already done.

Write `_plan/_todo.md`. Do NOT wait for approval — this is autopilot.

### 2. Delegate to builder-agent

For each uncompleted task in `_todo.md`:
- Delegate to builder-agent with:
  - The TODO entry
  - Milestone goals (`_goal/`)
  - Milestone contracts (`_contract/`)
  - Relevant global rules (`.chief/_rules/`)
  - Verification expectations
- Wait for builder to complete
- Mark task `[x]` in `_todo.md` when done

### 3. Handle blockers and ambiguity

**Auto mode:**
- If builder reports a blocker or ambiguity → chief-agent picks the best option and continues.
- Document the decision in the batch report (see below).
- Builder-agent should escalate to chief-agent when possible before giving up.

**Safe mode:**
- If builder reports a blocker or ambiguity → **STOP** and present the issue to the user with options.
- Wait for user decision, then continue.

### 4. Repeat

After completing a batch, check if the milestone goals are fully met:
- If more work remains → go back to step 1, create next batch.
- If goals are met → write final batch report and stop.

## Batch Report

After each batch (or when stopping), write a report to:

`.chief/<milestone>/_report/autopilot-run-batch-<N>.md`

Where `<N>` is the next available number (1, 2, 3...).

The report MUST contain these sections:

```md
# Autopilot Run Batch <N>

## Mode
auto | safe

## Summary
What was accomplished in this batch.

## Tasks Completed
- task-1: ...
- task-2: ...

## Decisions Made (auto mode only)
For each ambiguity encountered:
- **Issue:** what was ambiguous
- **Options:** what choices existed
- **Chosen:** which option was picked
- **Reason:** why

## Backlog
Remaining work not yet done.

## User Action Needed
Items that require human decision or manual intervention.
```

## Rules

- NEVER start without goals and contracts existing.
- NEVER skip the entry confirmation.
- In auto mode, NEVER stop for human input — make decisions and document them.
- In safe mode, ALWAYS stop on ambiguity — never guess.
- Follow the rules hierarchy: AGENTS.md > .chief/_rules > milestone goals.
- Builder-agent handles all implementation. Chief NEVER writes code.
- Tester-agent is NOT used unless the user explicitly requests it.
