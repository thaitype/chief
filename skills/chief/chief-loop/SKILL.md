---
name: chief-loop
description: Work a story's ticket frontier end to end, one ticket at a time via /chief-build, writing one report per ticket instead of one per batch. Standard mode (default) has no mandatory TDD or code review per ticket; strict mode adds both. When a ticket hits ambiguity, a throwaway decision-support agent proposes options; you still make the final call and the report captures the reasoning. Requires the goal and contract to exist. Use "/chief-loop" for standard or "/chief-loop strict" for strict.
---

Work the full ticket frontier of a story — ticket after ticket — until both the goal and the
contract are satisfied, recording a decision-aware report for every ticket instead of one
combined report per batch.

**Storage location:** `.chief/` is the default. If `.chief.config.md` exists at the repo
root, resolve `storage-root:` from it first and use that path everywhere below instead.

This builds directly on `chief-autopilot`'s auto mode. If you want the "stop and ask a human on
ambiguity" behavior, use `chief-autopilot safe` instead — `chief-loop` only runs in auto mode;
it doesn't have a safe-mode equivalent.

## Arguments

- No argument or `standard` → **standard mode** (default). Every ticket is built via
  `/chief-build` in standard mode — no mandatory TDD or `/chief-review-code` per ticket. Local
  verification (typecheck, tests) still runs inside `/chief-build` either way.
- `strict` → **strict mode**. Every ticket is built via `/chief-build` in strict mode — TDD at
  pre-agreed seams plus a mandatory `/chief-review-code` pass before every commit. Use this when
  the extra per-ticket rigor is worth the extra time.

If the mode wasn't given as an argument, resolve it at Entry Confirmation below instead of
assuming — but never block on it: no answer there means standard, same as no argument here.

## Prerequisite Check

Before doing anything:

1. Identify the active story directory under `.chief/`.
2. Check that `_goal/` has at least one non-empty file.
3. Check that `_contract/` has at least one non-empty file.

If either is missing → **STOP**. Tell the user:
> "A goal and contract are required for chief-loop. Run `/chief-plan` first."

Do NOT proceed.

## Entry Confirmation

Present the current goal and contract to the user in a brief summary (file names + 1-line
description each).

Ask one question, folding in the mode check only if no `standard`/`strict` argument was given:
> "Goal and contract look correct? Proceed with chief-loop, or use `/chief-plan` to revise
> first? (And: standard mode — the default, no TDD/review mandate — or strict mode — TDD + code
> review on every ticket?)"

If the user says revise → stop.
If the user confirms but doesn't answer the mode part (or there's nothing to answer because an
argument already set it) → proceed, mode = standard unless an argument said `strict`.

**Optional:** if the `loop-readiness` skill is available, offer to run it against this story's
tickets before proceeding — it reviews whether there's enough feedforward/feedback coverage to
run safely unattended. If it flags pre-existing gates the tickets depend on, also offer
`loop-preflight` to actually run them and confirm they still pass. Both are suggestions, not
requirements; proceed without them if the user declines.

## The Loop (spans as many tickets as it takes)

### 1. Compute the frontier

Scan `.chief/story-N/_tickets/` for tickets with `Type: implementation`, `Status: open`, and
every `Blocked by` entry already `resolved`. That's the frontier — the tickets takeable right
now. If the frontier is empty but tickets remain (all blocked, or all claimed), stop and report
why rather than looping uselessly.

If no tickets exist at all yet, run `/chief-plan` Phase 3 yourself to create the first batch — do
NOT wait for its approval gate on this, same override `chief-autopilot` uses; this skill only has
an auto-mode-like behavior (see Rules), so stopping here to wait on a human would contradict its
own "never stop for ambiguity" rule.

### 2. Work the frontier, one ticket at a time

For each ticket in the frontier, in order:

1. Set its `Status: claimed`.
2. Invoke `/chief-build <ticket-id>` **in the mode resolved at Entry Confirmation** (standard or
   strict), spawned as its own subagent so this ticket gets isolated context (don't run the
   build inline in this session — that accumulates every ticket's exploration noise into one
   context, which is exactly what `/chief-build`'s "clear context, build one ticket, clear
   again" rhythm exists to avoid).
3. Wait for `/chief-build` to complete.
4. If it reports a blocker or ambiguity (its escalation format), see **Handling Ambiguity**
   below before moving on.
5. Set the ticket's `Status: resolved`.
6. Recompute the frontier — resolving this ticket may have unblocked others.
7. Write this ticket's report (see **Ticket Report** below) immediately, before starting the
   next one. Don't batch report-writing up to the end.

### 3. Check for story completion

After the frontier empties (every ticket resolved, or every remaining ticket permanently
blocked):
- If the goal isn't fully met, or the implementation doesn't yet satisfy the contract → run
  Phase 3 of `/chief-plan` yourself for the next batch of tickets (same no-approval override as
  above — don't wait), then return to step 1.
- If both the goal and the contract are satisfied → stop. The story is done.

There's no cap on how many rounds this takes — keep going until both conditions hold.

## Handling Ambiguity

When `/chief-build` reports a blocker or ambiguity on a ticket:

1. Spawn a **throwaway agent** (a plain `Agent` tool call — not a persistent agent type) with a
   self-contained prompt: describe the ambiguity, the options `/chief-build` was aware of, and
   ask it to propose 2–3 concrete options with a one-line trade-off each. This agent's only job
   is to help think through the options — it does not decide, and it does not write any files.
2. You review the proposed options and **pick one yourself** — you are always the final
   decision-maker.
3. Record the issue, the options considered, and the choice + reasoning in that ticket's report
   (see below).

If a ticket has no ambiguity, skip this section entirely — no agent gets spawned, and the
ticket's report is just a short, factual summary.

## Ticket Report

For every ticket (not just the ones with ambiguity), write:

`.chief/story-N/_report/ticket-<id>-report.md`

```md
# Ticket <id> Report

## Ticket
One or two lines on what this ticket was.

## Outcome
done | blocked

## Decision
(Omit this whole section if the ticket had no ambiguity.)
- **Issue:** what was ambiguous or blocking
- **Options considered:** the options the decision-support agent proposed
- **Chosen:** which one, and why

## Notes
Anything worth carrying into the next ticket or round.
```

## Rules

- NEVER start without a goal and contract existing.
- NEVER skip the entry confirmation.
- NEVER stop for human input on ambiguity — this skill only has an auto-mode-like behavior.
  Point the user at `chief-autopilot safe` if they want stop-and-ask. This includes re-planning:
  running `/chief-plan` Phase 3 for a new ticket batch never waits on its approval gate here,
  same as it never waits inside `chief-autopilot` — stopping for that would be the same
  contradiction as stopping for a build ambiguity.
- Mode (standard/strict) is resolved once, at Entry Confirmation, and used for every `/chief-build`
  call this run — don't re-ask or switch modes mid-run.
- You are ALWAYS the one who makes the final decision on an ambiguity — the decision-support
  agent only proposes options, never decides, never writes files.
- Write a report for every ticket, immediately after it resolves — never batch report-writing
  up.
- Work the frontier as it computes — don't pre-plan a fixed batch size; take whatever's
  unblocked.
- Story completion requires BOTH the goal being met AND the contract being satisfied — meeting
  the goal alone isn't enough to stop. Matt's `implement`/`implement-spec` have no equivalent
  check (their "done" is either nonexistent or pure task-graph exhaustion) — this check is
  Chief's own and doesn't come from anywhere else, so don't drop it.
- `/chief-build` handles all implementation. This skill NEVER writes code directly.
- `/chief-test` is NOT used unless the user explicitly requests it.
