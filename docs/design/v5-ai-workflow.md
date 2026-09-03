# Chief v5 — AI Workflow Redesign

**Status:** Draft, pending approval. Nothing in this doc has been implemented. No skill or agent
file has been changed — this is a design record from a grill-design consultation session.

**Branch:** `design/v5-ai-workflow`

## Motivation

Chief v4's planning pipeline (`goal → contract → todo → task-spec`) predates a set of ideas
that [mattpocock/skills](https://github.com/mattpocock/skills) has since worked out well:
a configurable issue-tracker backend instead of a hardcoded path, a ticket task-graph instead
of a flat todo list, a thin single-purpose `implement` step, and `wayfinder` for planning work
too large for one session. v5 pulls these ideas into Chief without losing what Chief already
does that matt's skillset doesn't: milestone-scoped review gates, an auto/safe-mode autopilot
loop, and long-running/integration verification.

Two structural moves ship together in v5:

1. **New skills**: `/chief-wayfinder`, `/chief-build`, `/chief-test`, `/chief-review-code`.
2. **Breaking rewrite** of the existing `chief-*` skill group in place (not a new sibling
   skill group) — `v4 → v5`, with a `release/v4` branch cut before merge so existing users can
   pin the old behavior.

## Pipeline

```
milestone (root container — "milestone" as a name is kept; still Level 3 of the rules
           hierarchy, still the container between global rules and a single ticket)
  │
  ├─ /chief-wayfinder (optional, explicit invocation, callable at any point in the
  │     milestone's life — not only before /chief-plan, not auto-detected)
  │     → produces decision-tickets (research / prototype / grilling / task),
  │       resolved one at a time, same "frontier" model as matt's wayfinder
  │
  ├─ /chief-plan
  │     Phase 0 now opens with an explicit choice: "grill normally, or use
  │     /chief-wayfinder for this milestone?" — this is the discovery surface for
  │     wayfinder; the skill itself must still be invoked explicitly, this just
  │     means the user doesn't need to already know it exists.
  │     Phase 1 → _goal/goal.md   (kept as its own file/gate)
  │     Phase 2 → _contract/contract.md   (kept as its own file/gate)
  │     Both phases keep Chief's existing 2-phase approve-then-continue gate —
  │     this is deliberately NOT merged into one to-spec-style file (see
  │     "Decisions" #6 below), because the two-gate review is Chief's own value
  │     that matt's single-shot to-spec doesn't have.
  │     Phase 3 → tickets, not _todo.md (see #1)
  │
  ├─ tickets/  (to-tickets-style vertical slices, each with explicit blocking
  │     edges, tracer-bullet sized to one fresh context window)
  │     — lives in the SAME store as wayfinder's decision-tickets, distinguished
  │       by a type/label field (decision vs implementation), matching how matt's
  │       own vocabulary treats a "Decision ticket" as just a labelled Issue
  │
  ├─ /chief-build <ticket>        (per ticket, see #3)
  ├─ /chief-test <ticket|milestone>   (long-running/integration verification, see #3)
  ├─ /chief-review-code               (called as part of /chief-build, see #7)
  │
  └─ /chief-loop, /chief-autopilot
        Still the real orchestrators: pick the next frontier ticket, delegate to
        /chief-build, mark ticket status, write milestone-level reports, and —
        unlike anything in matt's skillset — check "goal met AND contract
        satisfied" as the actual termination condition for the loop.
```

## Decisions

### 1. Ticket model replaces the todo list

`_plan/_todo.md` (the batch-of-3–5 checklist) is removed entirely. `chief-loop` /
`chief-autopilot` work a **ticket frontier** instead: any ticket whose blockers are all
resolved is takeable, tracked via a `Status: claimed | resolved` field per ticket (same
convention matt's local-markdown tracker uses), not a shared checklist file. This is the
single biggest mechanical change in v5 — everything else follows from it.

### 2. "Milestone" is kept as a name

Considered renaming to "epic"/"initiative", or dropping the layer entirely so a ticket-bearing
spec is the top-level unit. Kept "milestone": it is Level 3 of the existing rules hierarchy
(`AGENTS.md > _rules/ > milestone-N/_goal/`), `chief-plan` already supports extending one
milestone with multiple goal/contract pairs over time, and a `/chief-wayfinder` map's scope is
smaller now (nested inside one milestone) rather than spanning several — so milestone remains
a genuinely distinct grain, not a redundant wrapper.

### 3. `/chief-wayfinder`: explicit, not auto-detected, callable anytime

- Triggered only by explicit invocation (`/chief-wayfinder`), never by the model deciding on
  its own that a milestone "looks foggy enough."
- Discoverable via `/chief-plan` Phase 0, which now asks the user to choose grill-vs-wayfinder
  up front, rather than requiring the user already know the skill exists.
- Not restricted to running before `/chief-plan` starts — the milestone can already exist, and
  `/chief-wayfinder` can be invoked again mid-milestone if new fog surfaces later.
- Feeds `/chief-plan`'s Phase 0/1/2: resolved decision-tickets are read as already-settled
  input, so Phase 0 only grills what wayfinder didn't already cover.

### 4. Storage backend: full abstraction, local-only implementation

Adopts matt's pattern of a per-repo pointer/config file that every skill reads instead of
hardcoding a path — but, unlike matt (who ships GitHub/GitLab/local out of the box), v5 ships
**only the local backend**, still named `.chief/` (matching matt's own practice of a fixed
name per backend choice — the backend is configurable, its name isn't). GitHub/GitLab/other
backends are a seam for later, not implemented now.

Even though there is only one working backend at launch, `/chief-init` (or a new small setup
step) explicitly surfaces a "where should planning artifacts live?" question rather than
silently defaulting — this is a deliberate choice to make "not fixed" visible from day one,
not just true internally.

### 5. Termination condition stays Chief's own

Matt's `implement` explicitly has no completion step ("it ends at the commit and never
touches the work item... close the ticket and reconcile the criteria yourself" —
`docs/engineering/implement.md`). The unreleased `implement-spec` defines "done" as pure
task-graph exhaustion, with no check against any upstream goal or spec. Neither gives
`chief-loop` / `chief-autopilot` what they need: **the termination check — "goal met AND
contract satisfied" — is Chief's own logic and is kept unchanged in v5.**

### 6. `/chief-build` (replaces `builder-agent`, absorbs matt's `implement`)

- New skill, not a call into matt's `/implement` and not a rename of it — the user does not
  want any direct reference to an unmodified third-party skill file.
- Internal recipe follows matt's 5 beats: TDD at pre-agreed seams → typecheck often → run a
  single test file often → run the full suite once at the end → code review
  (`/chief-review-code`, see #7) → commit.
- Everything `builder-agent.md` had that matt's `implement` doesn't — the escalation format,
  the progress-based auto-fix policy, the milestone-scoping boundary, the commit-message
  convention — is kept, folded into the same skill file.
- **Not an orchestrator.** Scope is deliberately narrow: given one ticket, build it correctly.
  It does not decide what's next and does not check milestone completion — same self-description
  matt gives `/implement` ("it never reopens the plan... whatever was settled upstream is the
  input"). `chief-loop` / `chief-autopilot` remain the orchestrators.
- Two invocation surfaces, one file: a human can run `/chief-build <ticket>` directly at the
  top level (replacing the old `builder-agent: implement task-1` manual-invocation UX); or
  `chief-loop`/`chief-autopilot` spawn it as a throwaway subagent per ticket, so each ticket
  gets isolated context (mirrors matt's own stated rhythm: "clear context, implement one
  ticket, commit, clear again").
- **Open technical question, not blocking the design**: the exact mechanism by which an
  orchestrator skill spawns a subagent that follows another skill's instructions needs a
  prototype during implementation — worst case, the spawn prompt embeds `/chief-build`'s
  SKILL.md content verbatim rather than referencing it by name.

### 7. `/chief-review-code` (new — adopts matt's `code-review`)

Adopts matt's two-axis review (**Standards**: does the diff follow this repo's documented
coding standards + a fixed Fowler-smell baseline; **Spec**: does the diff faithfully implement
what was asked), run as two parallel throwaway sub-agents so neither axis pollutes the other's
context, reported separately (never re-ranked against each other).

Mapped onto Chief's own artifacts instead of matt's "issue tracker" vocabulary:

- **Standards source**: `.chief/_rules/_standard/**` (already exists in Chief).
- **Spec source**: the ticket's originating `_goal/goal.md` + `_contract/contract.md`, not a
  freeform spec file.

Called as the review beat inside `/chief-build`'s recipe (#6), and directly invocable by a
human the same way matt's `/code-review` is.

### 8. All persistent subagents (`.agents/agents/*`) are deprecated

| v4 file | v5 disposition |
|---|---|
| `chief-agent.md` | Deprecated outright — its content duplicates `chief-plan`/`chief-loop`/`chief-autopilot`'s own (more precise) instructions. No replacement identity needed: "the orchestration brain" is just whichever `chief-*` skill is currently running. |
| `builder-agent.md` | Folded into `/chief-build` (#6). |
| `tester-agent.md` | Renamed and folded into **`/chief-test`** — same dual-invocation pattern as `/chief-build`: human-callable directly, and a spawn target for `chief-loop`/`chief-autopilot` when long-running/integration/external validation is needed. Scope (short deterministic tests are `/chief-build`'s job; long-running/integration/external is `/chief-test`'s) is unchanged from today's tester-agent boundary. |
| `answer-verifier-agent.md` | Folded inline into whichever skill needs per-answer verification against the codebase — `/chief-grill`, and now also `/chief-wayfinder`'s `grilling`-type tickets. Spawned as a throwaway subagent per call; no persistent file. |

Consequence: `.agents/agents/` is empty/removed for v5. `/chief-install`'s "Install
subagents? Yes/No" step is meaningless as written and must be removed or repurposed.

### 9. Approach: breaking change in place, not a new sibling skill group

All of the above modifies `skills/chief/*` directly rather than shipping a parallel,
differently-named skill group. Justification: every decision above already assumes this (the
existing skill names change behavior; old agent files are removed outright) — running two
systems side by side was never actually proposed once the details were worked out.

### 10. Versioning and migration

- Cut `release/v4` from current `main` **before** merging v5 changes — matches the existing
  `release/v1` / `release/v2` / `release/v3` convention already in this repo.
- `main` becomes v5 once merged. Existing users pin `#v4.0.0` or `release/v4` to keep the old
  behavior.
- **No automated `.chief/` migration script.** A milestone in flight on v4 finishes on a
  pinned v4 checkout; there is no supported path to migrate a half-done v4 milestone's
  `_todo.md`/`task-N.md` into v5's ticket shape mid-flight.
- README version badge, version-history section, and `/chief-upgrade` pin instructions need
  updating to add the v5 entry (there is precedent for deprecating an agent across a version
  bump already — v4's changelog line says "`answer-verifier-agent` replaces deprecated
  `review-plan-agent`").

## Open items (not blocking, need resolving during implementation)

- Where matt's to-spec sections that Chief's `goal`/`contract` don't currently have —
  **Testing Decisions** and **Out of Scope** — land. Likely new subsections of
  `contract.md`, not decided.
- Exact ticket file template and status vocabulary for the local backend (mirrors matt's
  `.scratch/<feature>/issues/NN-slug.md` with `Status:`/`Blocked by:` fields, adapted under
  `.chief/milestone-N/`) — naming (`_tickets/`? `_plan/tickets/`?) not decided.
- Exact location/filename of the storage-backend pointer file (#4) — not decided; matt's own
  equivalent is `docs/agents/issue-tracker.md`.
- The subagent-spawn mechanism noted under #6.

## Non-goals for v5

- GitHub/GitLab/Linear backend implementations (seam only, see #4).
- A `researcher`/exploration throwaway subagent ahead of `/chief-build` (matt's
  `implement-spec` pattern) — considered and explicitly deferred; scope creep risk against an
  already-large change set.
- Concurrent/parallel ticket execution (matt's `implement-spec` "maximum concurrency" model) —
  Chief's loop stays one-ticket-at-a-time, unchanged from v4.
