---
name: loop-readiness
description: Review the readiness of a plan for an unattended/autonomous loop — checks whether it has enough feedforward guidance and feedback verification to run safely. Use when the user has a plan (or an idea) for a loop/agent that will run multiple iterations without a human checking every step, and wants to know how well-instrumented it is before starting. Works from an existing plan file or from a live conversation.
---

# Loop readiness review

This is a **readiness review**, not a gate. It never produces a pass/fail verdict or a
single overall score — it reports what's present, what's missing, and what to consider
per dimension, so the person deciding whether to start the loop has the full picture.

A "loop" here means any agent/process that runs multiple iterations with **no human
checking every step** — an autopilot, a scheduled job, a long-running agent workflow, or
anything similar. The review looks at the *plan* for that loop, not the loop itself —
nothing gets executed during this review.

## Step 1: Get the plan

- If a plan was given — as text or a file path — use it.
- If not, use the `grill-design` skill if available. Otherwise, **interview the user
  one question at a time** to build up an understanding of the plan — what it's trying
  to do, and how it's supposed to know if it's working. One question per turn, never
  ask a compound question.

## Step 2: Review each dimension

Walk through all four. For each, note what's present, what's missing, and how deep the
coverage is — there's no fixed checklist to fill in mechanically; use judgment about how
much depth this specific loop actually needs.

### 2.1 Definition of Ready (DoR)

Is there something written down that defines what this loop is for and where its edges
are? Depending on the loop, this could include: a goal statement, explicit non-goals /
out-of-scope items, a contract (data shapes, API boundaries), a UI mock or diagram — go
as deep as makes sense for the stakes involved. A one-line goal can be enough for a small
loop; a loop that touches production data probably needs more.

### 2.2 Feedforward

Feedforward is guidance given to the loop *before or during* each iteration, to raise the
odds it does the right thing in the first place — conventions docs, skills, contracts,
bootstrap scripts, code-mod tooling, anything the loop reads or is constrained by while
acting. Note whether this guidance is:
- **Computational** — a deterministic tool/script/generator it must go through
- **Inferential** — a doc/skill it reads and applies judgment to
- Both, or neither

### 2.3 Feedback

Feedback is verification *after* an iteration/action, to catch bad outcomes. A healthy
loop usually needs at least one kind, but which kinds and how many is a judgment call
based on what the loop can actually break. Look for:

- **Computational / mock / dry-run** — unit tests, linters, type checks, structural
  checks. Cheap and fast, run on every iteration, but can pass while missing real-world
  failures — note this trade-off if it's the *only* feedback mechanism present.
- **Real-environment** — verification against the actual system the loop will operate
  on. Note whether it exists, and whether it looks safe to run unattended (see the
  concrete checks under Step 3 — they apply here).
- **Inferential** — an LLM-as-judge or review step that makes a semantic judgment call
  on the outcome, rather than a deterministic check.

### 2.4 Definition of Done (DoD)

Does the plan say how the loop actually stops? There's no required vocabulary or fixed
set of terminal states — a loop can end however its author defines. Note whether the
plan accounts for more than just a clean success path: what happens on failure, and what
happens if the loop can't tell whether it succeeded (ambiguous outcome, missing
precondition, etc.) — these are worth surfacing as a gap if absent, without requiring
any particular fix.

## Step 3: Report

For each of the 4 dimensions above, produce:
- a short checklist of what's present / missing / partial
- a one-line qualitative note for that dimension only (e.g. "solid", "thin", "missing")

Do **not** synthesize these into one overall score or label — the four notes stand on
their own; the reader weighs them.

Then add **actionable recommendations** tied to the specific gaps found — concrete next
steps, not just "this is missing." For any real-environment feedback found in 2.3, check
directly (this is static-review-friendly — usually a clear yes/no from the plan as
described) and recommend fixes for whichever are missing:
- Is there a **preflight step** that verifies credentials/permissions actually work
  *before* the loop starts doing real work (not just assumed to work)? If not, recommend
  adding one — test against the real system once, before the loop runs unattended.
- For any feedback mechanism the plan treats as already existing (a gate script, test
  suite, a check inherited from earlier work) — as opposed to one the loop will build
  fresh — has it been smoke-tested since the plan was written? A plan can describe a gate
  accurately in a static read while an unrelated change between planning and execution
  silently breaks it (e.g. a hardcoded path renamed elsewhere); only actually running the
  gate reveals this, and a static review is blind to it by design. If not, recommend
  running the `loop-preflight` skill on it before trusting it as available feedback —
  that skill actually runs it, so this review itself still doesn't have to violate the
  "never execute the plan" rule below.
- Is access **least-privilege** scoped — no broader than the task needs? If not,
  recommend narrowing it.
- Is it **read-only by default**? If the loop only needs to observe but holds write
  access anyway, recommend dropping it.
- If the loop genuinely needs to write, is that write scoped to an environment that's
  actually safe to write to (a sandbox, a non-production target, or similar) rather than
  a write capability bolted onto a read-oriented check? If not, recommend fixing the
  scope before the loop runs unattended.

Other recommendation examples:
- Nothing written down about the loop's goal or edges (DoR) → recommend writing at least
  a one-line goal and explicit non-goals before starting, so scope doesn't drift mid-run
- No guidance/conventions for the loop to follow (Feedforward) → recommend pointing it at
  existing docs/skills/contracts, or writing a short one if none exist
- Only mock/dry-run feedback, nothing against the real target → recommend adding at
  least one real-environment check, or explicitly accepting the risk if the loop's
  stakes are low
- No escalation/blocked outcome in the DoD → recommend adding a defined way for the loop
  to stop and hand off to a human when it can't tell if it succeeded

Recommendations are suggestions to weigh, not requirements to satisfy before proceeding.

## Rules

- NEVER execute anything from the plan being reviewed — this is a static review of what's
  described, not a test of whether it actually works.
- NEVER produce a pass/fail verdict or a single overall score/label — dimension-level
  notes only.
- NEVER require a specific vocabulary for DoD terminal states or a fixed checklist for
  DoR — assess what's there against what this specific loop's stakes call for.
- NEVER write to any other file — like a grill session, this review lives in the
  conversation (or is returned as a response), unless the user explicitly asks for it to
  be saved somewhere.
