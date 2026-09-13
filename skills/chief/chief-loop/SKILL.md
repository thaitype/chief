---
name: chief-loop
description: Run chief-agent across as many batches as it takes to finish a milestone, writing one report per task instead of one per batch. When a task hits ambiguity, a throwaway decision-support agent proposes options; chief-agent still makes the final call and the report captures the reasoning. Requires goals and contracts to exist. Use "/chief-loop".
---

Run chief-agent across the full milestone — batch after batch — until both the goals and
the contracts are satisfied, recording a decision-aware report for every task instead of
one combined report per batch.

This builds directly on `chief-autopilot`'s auto mode. If you want the "stop and ask a
human on ambiguity" behavior, use `chief-autopilot safe` instead — `chief-loop` only runs
in auto mode; it doesn't have a safe-mode equivalent.

## Prerequisite Check

Before doing anything:

1. Identify the active milestone directory under `.chief/`.
2. Check that `_goal/` has at least one non-empty file.
3. Check that `_contract/` has at least one non-empty file.

If either is missing → **STOP**. Tell the user:
> "Goals and contracts are required for chief-loop. Run `/chief-plan` first."

Do NOT proceed.

## Entry Confirmation

Present the current goals and contracts to the user in a brief summary (file names + 1-line description each).

Ask one question:
> "Goals and contracts look correct? Proceed with chief-loop, or use `/chief-plan` to revise first?"

If the user says revise → stop.
If the user confirms → proceed.

**Optional:** if the `loop-readiness` skill is available, offer to run it against this
milestone's plan before proceeding — it reviews whether the plan has enough
feedforward/feedback coverage to run safely unattended. If it flags pre-existing gates
the plan depends on, also offer `loop-preflight` to actually run them and confirm they
still pass. Both are suggestions, not requirements; proceed without them if the user
declines.

## Outer Loop (spans as many batches as it takes)

### 1. Create or update TODO

Read existing `_plan/_todo.md` if present. Create the next batch of 3–5 tasks based on
goals, contracts, and what's already done — same small-batches principle as
`chief-autopilot`.

Write `_plan/_todo.md`. Do NOT wait for approval — this is autopilot-style, no pausing
for plan review.

### 2. Work the batch, one task at a time

For each uncompleted task in the current batch:

1. Delegate to builder-agent with:
   - The TODO entry
   - Milestone goals (`_goal/`)
   - Milestone contracts (`_contract/`)
   - Relevant global rules (`.chief/_rules/`)
   - Verification expectations
2. Wait for builder to complete.
3. If builder reports a blocker or ambiguity, see **Handling Ambiguity** below before
   moving on.
4. Mark the task `[x]` in `_todo.md`.
5. Write that task's report (see **Task Report** below) — do this immediately, before
   starting the next task. Don't batch report-writing up to the end.

### 3. Check for milestone completion

After the batch is fully worked:
- If the goals aren't fully met, or the implementation doesn't yet satisfy the
  contracts → go back to step 1 and create the next batch.
- If both goals and contracts are satisfied → stop. The milestone is done.

There's no cap on how many batches this takes — keep going until both conditions hold.

## Handling Ambiguity

When builder-agent reports a blocker or ambiguity on a task:

1. Spawn a **throwaway agent** (a plain `Agent` tool call — not a persistent agent type)
   with a self-contained prompt: describe the ambiguity, the options it's aware of, and
   ask it to propose 2–3 concrete options with a one-line trade-off each. This agent's
   only job is to help think through the options — it does not decide, and it does not
   write any files.
2. chief-agent reviews the proposed options and **picks one itself** — chief-agent is
   always the final decision-maker, same as in `chief-autopilot`.
3. Record the issue, the options considered, and the choice + reasoning in that task's
   report (see below).

If a task has no ambiguity, skip this section entirely — no agent gets spawned, and the
task's report is just a short, factual summary.

## Task Report

For every task (not just the ones with ambiguity), write:

`.chief/<milestone>/_report/task-<task-id>-report.md`

Using the same `<task-id>` as `_plan/task-<task-id>.md`, so the two files map 1:1.

```md
# Task <task-id> Report

## Task
One or two lines on what this task was.

## Outcome
done | blocked

## Decision
(Omit this whole section if the task had no ambiguity.)
- **Issue:** what was ambiguous or blocking
- **Options considered:** the options the decision-support agent proposed
- **Chosen:** which one, and why

## Notes
Anything worth carrying into the next task or batch.
```

## Rules

- NEVER start without goals and contracts existing.
- NEVER skip the entry confirmation.
- NEVER stop for human input on ambiguity — this skill only has an auto-mode-like
  behavior. Point the user at `chief-autopilot safe` if they want stop-and-ask.
- chief-agent is ALWAYS the one who makes the final decision on an ambiguity — the
  decision-support agent only proposes options, never decides, never writes files.
- Write a report for every task, immediately after that task completes — never batch
  report-writing up.
- Keep the small-batches principle (3–5 tasks per TODO cycle) — only the report
  granularity changed, not the planning cadence.
- Milestone completion requires BOTH goals met AND contracts satisfied — meeting the
  goal alone isn't enough to stop.
- Builder-agent handles all implementation. Chief NEVER writes code.
- Tester-agent is NOT used unless the user explicitly requests it.
