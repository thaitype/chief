---
name: chief-loop
description: Work a story's ticket frontier end to end via /chief-build, one report per ticket. Sequential by default (one ticket at a time); `parallel`/`parallel:<N>` builds up to N tickets at once, each in its own isolated git worktree, merged back as each finishes. Standard mode (default) has no mandatory TDD or code review per ticket; strict mode adds both. When a ticket hits ambiguity (or a parallel merge conflicts), a throwaway decision-support agent proposes options; you still make the final call and the report captures the reasoning. Requires the goal and contract to exist. Use "/chief-loop", "/chief-loop strict", "/chief-loop parallel:3", etc.
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

Two independent settings, space-separated, in any order — e.g. `/chief-loop`,
`/chief-loop strict`, `/chief-loop parallel:3`, `/chief-loop strict parallel:3`.

**Mode:**

- No argument or `standard` → **standard mode** (default). Every ticket is built via
  `/chief-build` in standard mode — no mandatory TDD or `/chief-review-code` per ticket. Local
  verification (typecheck, tests) still runs inside `/chief-build` either way.
- `strict` → **strict mode**. Every ticket is built via `/chief-build` in strict mode — TDD at
  pre-agreed seams plus a mandatory `/chief-review-code` pass before every commit. Use this when
  the extra per-ticket rigor is worth the extra time.

If the mode wasn't given as an argument, resolve it at Entry Confirmation below instead of
assuming — but never block on it: no answer there means standard, same as no argument here.

**Concurrency:**

- No argument → **sequential** (default). One `/chief-build` subagent in flight at a time, in
  the main checkout, today's behavior unchanged.
- `parallel` → **parallel**, limit resolved at Entry Confirmation below (asked, same as an
  unspecified mode).
- `parallel:<N>` → **parallel**, limit `N`, nothing to ask.

Parallel mode builds up to the limit's worth of tickets at once, each in its own isolated git
worktree (never the main checkout), merging each back into the story branch as it finishes — see
**Parallel Execution** under The Loop for the full mechanics. If concurrency wasn't given as an
argument, resolve it at Entry Confirmation instead of assuming — no answer there means
sequential, same as no argument here.

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

Ask one question, folding in whichever of mode/concurrency weren't already set by an argument:
> "Goal and contract look correct? Proceed with chief-loop, or use `/chief-plan` to revise
> first? (And: standard mode — the default, no TDD/review mandate — or strict mode — TDD + code
> review on every ticket? Sequential — the default, one ticket at a time — or parallel, and if
> so, how many at once?)"

If the user says revise → stop.
If the user confirms but leaves a part unanswered (or there was nothing to ask because an
argument already set it) → mode defaults to standard, concurrency defaults to sequential. A
parallel answer with no number given still needs a limit — ask that one follow-up before
proceeding; don't guess a number.

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

### 2. Work the frontier

How, depends on the concurrency resolved at Entry Confirmation.

#### Sequential (default)

For each ticket in the frontier, in order:

1. Set its `Status: claimed`.
2. Invoke `/chief-build <ticket-id>` **in the mode resolved at Entry Confirmation** (standard or
   strict), spawned as its own subagent so this ticket gets isolated context (don't run the
   build inline in this session — that accumulates every ticket's exploration noise into one
   context, which is exactly what `/chief-build`'s "clear context, build one ticket, clear
   again" rhythm exists to avoid). Runs in the main checkout — no worktree involved.
3. Wait for `/chief-build` to complete.
4. If it reports a blocker or ambiguity (its escalation format), see **Handling Ambiguity**
   below before moving on.
5. Set the ticket's `Status: resolved`.
6. Recompute the frontier — resolving this ticket may have unblocked others.
7. Write this ticket's report (see **Ticket Report** below) immediately, before starting the
   next one. Don't batch report-writing up to the end.

#### Parallel Execution

Maintain a **pool** of tickets in flight, sized up to the concurrency limit — never more.
`/chief-build`'s own working-directory awareness (see its own file) is what makes this safe: two
builds must never share a directory, so each pooled ticket gets its own isolated git worktree,
never the main checkout.

**Filling a pool slot**, for the next eligible ticket in the (recomputed) frontier:

1. Set its `Status: claimed` in the main checkout.
2. Create a git worktree for it, branched from the story branch's **current tip** at this exact
   moment (so it starts from whatever earlier parallel tickets have already merged back — this
   is what keeps conflicts rarer as a round progresses): `git worktree add <path> -b
   <story-branch>-ticket-<id> <story-branch>`.
3. Invoke `/chief-build <ticket-id>` **in the mode resolved at Entry Confirmation**, spawned as
   its own subagent, explicitly telling it to operate and commit inside that worktree's
   directory (see `/chief-build`'s own Working directory note) rather than the main checkout.
4. Do **not** wait for it before filling another free slot — keep launching into free slots,
   up to the limit, as long as the frontier has eligible tickets left. This is what makes it
   parallel.

**When a pooled ticket's `/chief-build` completes:**

5. If it reports a blocker or ambiguity, see **Handling Ambiguity** below before continuing.
6. Rebase that ticket's worktree branch onto the story branch's current tip, then merge it in
   (fast-forward if the rebase was clean). If the rebase or merge itself hits a conflict, that's
   also handled by **Handling Ambiguity**.
7. Remove the worktree and delete its temporary branch.
8. Set the ticket's `Status: resolved` in the main checkout.
9. Write this ticket's report (see **Ticket Report** below) immediately.
10. Recompute the frontier — this merge may have unblocked others — and immediately pull the
    next eligible ticket into the now-free slot (step "Filling a pool slot" above). **Don't wait
    for the rest of the pool to finish first** — a slot refills the moment it frees, independent
    of how long its neighbors take. This is deliberate: `chief-loop` already dropped v4's
    fixed-size batching for exactly this reason (see Rules), and waiting for a whole parallel
    cohort before refilling would quietly reintroduce it.

Keep going until the frontier is empty **and** the pool has fully drained (nothing in flight,
nothing eligible left to pull in).

### 3. Check for story completion

After the frontier empties and (in parallel mode) the pool drains — every ticket resolved, or
every remaining ticket permanently blocked:
- If the goal isn't fully met, or the implementation doesn't yet satisfy the contract → run
  Phase 3 of `/chief-plan` yourself for the next batch of tickets (same no-approval override as
  above — don't wait), then return to step 1.
- If both the goal and the contract are satisfied → stop. The story is done.

There's no cap on how many rounds this takes — keep going until both conditions hold.

## Handling Ambiguity

Two things route here: `/chief-build` reporting a blocker or ambiguity on a ticket, **or** (in
parallel mode) a rebase/merge conflict while reconciling a pooled ticket's worktree branch back
into the story branch. Same handling either way:

1. Spawn a **throwaway agent** (a plain `Agent` tool call — not a persistent agent type) with a
   self-contained prompt: describe the issue, and what's known about it — for a build ambiguity,
   the options `/chief-build` was aware of; for a merge conflict, both sides of the diff — and
   ask it to propose 2–3 concrete options with a one-line trade-off each. This agent's only job
   is to help think through the options — it does not decide, and it does not write any files
   (a merge conflict resolution is still yours to commit, not the throwaway agent's).
2. You review the proposed options and **pick one yourself** — you are always the final
   decision-maker.
3. Record the issue, the options considered, and the choice + reasoning in that ticket's report
   (see below).

If a ticket has no ambiguity and (in parallel mode) its merge was clean, skip this section
entirely — no agent gets spawned, and the ticket's report is just a short, factual summary.

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
- Mode (standard/strict) and concurrency (sequential/parallel + limit) are each resolved once,
  at Entry Confirmation, and used for the whole run — don't re-ask or switch either mid-run.
- In parallel mode, every ticket build happens in its own isolated git worktree — never the main
  checkout, and never sharing a worktree with another in-flight ticket. Creating, merging, and
  removing those worktrees is entirely `chief-loop`'s own job; `/chief-build` only ever works and
  commits inside whatever directory it's told to use, and never touches worktree lifecycle
  itself.
- In parallel mode, never let the pool exceed the resolved limit, and never wait for the whole
  pool to finish before refilling a slot that's already free — refill it immediately (see
  Parallel Execution).
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
