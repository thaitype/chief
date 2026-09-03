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
does that matt's skillset doesn't: story-scoped review gates, an auto/safe-mode autopilot
loop, and long-running/integration verification.

Two structural moves ship together in v5:

1. **New skills**: `/chief-wayfinder`, `/chief-build`, `/chief-test`, `/chief-review-code`.
2. **Breaking rewrite** of the existing `chief-*` skill group in place (not a new sibling
   skill group) — `v4 → v5`, with a `release/v4` branch cut before merge so existing users can
   pin the old behavior.

## Naming: "milestone" → "story"

v4's `.chief/milestone-N/` is renamed to `.chief/story-N/` in v5. This is not cosmetic — it
was mis-scaled from the start. Chief's own tutorial example goal is `"Implement user listing
endpoint"` (`rules-hierarchy.md`), which is the size of a single Jira/GitHub/ClickUp **issue**,
not the size of a "Milestone" in any of those tools (a Milestone/Epic/Sprint groups *many*
issues, typically spanning weeks). Proof this actually confuses people: mid-session, this doc's
own author (the agent) defaulted to reading "milestone" as "the container GitHub Milestones
group issues into" — exactly backwards.

"story" fits the actual scale: Chief's unit (goal + contract + its tickets + reports) is the
size of one agile story / one GitHub Issue / one Jira ticket / one ClickUp ticket — a single
coherent piece of shippable work. This also sets up a clean future mapping once a GitHub
backend exists (deferred, see "Storage backend" below): **1 Chief story ≈ 1 GitHub Issue**, not
1 GitHub Milestone.

Every occurrence of "milestone" in skill files, docs, `AGENTS.md`, and directory names becomes
"story" (`.chief/milestone-N/` → `.chief/story-N/`, `_rules/_goal/` description "scoped to one
milestone" → "scoped to one story", etc.). Rules-hierarchy Level 3 stays structurally the same
(`_goal/`, `_contract/`), only the English word describing its scope changes.

## Pipeline

```
story (root container — .chief/story-N/, sized like one issue/ticket in any other tool)
  │
  ├─ /chief-wayfinder (optional, explicit invocation, callable at any point in the
  │     story's life — not only before /chief-plan, not auto-detected)
  │     → produces decision-tickets (research / prototype / grilling / task),
  │       resolved one at a time, same "frontier" model as matt's wayfinder
  │
  ├─ /chief-plan
  │     Phase 0 now opens with an explicit choice: "grill normally, or use
  │     /chief-wayfinder for this story?" — this is the discovery surface for
  │     wayfinder; the skill itself must still be invoked explicitly, this just
  │     means the user doesn't need to already know it exists.
  │     Phase 1 → _goal/goal.md   (kept as its own file/gate; gains an
  │                                "## Out of Scope" subsection, see below)
  │     Phase 2 → _contract/contract.md   (kept as its own file/gate; gains a
  │                                "## Testing Decisions" subsection, see below)
  │     Both phases keep Chief's existing 2-phase approve-then-continue gate —
  │     this is deliberately NOT merged into one to-spec-style file, because the
  │     two-gate review is Chief's own value that matt's single-shot to-spec
  │     doesn't have.
  │     Phase 3 → tickets, not _todo.md (see "Ticket model")
  │
  ├─ _tickets/  (to-tickets-style vertical slices, each with explicit blocking
  │     edges, tracer-bullet sized to one fresh context window — see "Ticket
  │     model" for the file shape)
  │     — lives in the SAME store as wayfinder's decision-tickets, distinguished
  │       by a `Type:` field (decision vs implementation), matching how matt's
  │       own vocabulary treats a "Decision ticket" as just a labelled Issue
  │
  ├─ /chief-build <ticket>            (per ticket, see "Execution skills")
  ├─ /chief-test <ticket|story>       (long-running/integration verification)
  ├─ /chief-review-code               (called as part of /chief-build)
  │
  └─ /chief-loop, /chief-autopilot
        Still the real orchestrators: pick the next frontier ticket, delegate to
        /chief-build, mark ticket status, write story-level reports, and —
        unlike anything in matt's skillset — check "goal met AND contract
        satisfied" as the actual termination condition for the loop.
```

## Decisions

### 1. Ticket model replaces the todo list

`_plan/_todo.md` (the batch-of-3–5 checklist) is removed entirely, and `_plan/` is renamed to
`_tickets/` (there is no more "plan" artifact distinct from the tickets themselves).
`chief-loop` / `chief-autopilot` work a **ticket frontier** instead: any ticket whose blockers
are all resolved is takeable.

**File shape** (`.chief/story-N/_tickets/<N>-<seq>-<slug>.md`, numbered `<story-number>-<seq>`,
e.g. `1-1-user-listing-schema.md` for story-1's first ticket):

```markdown
# 1-1: <ticket title>

Type: wayfinder:research | wayfinder:prototype | wayfinder:grilling | wayfinder:task | implementation
Status: open | claimed | resolved
Blocked by: 1-2, 1-5  (or "None (can start immediately)")

## Question / What to build
<the question, if a wayfinder:* ticket — or the end-to-end behaviour, if implementation>

## Acceptance Criteria
(implementation tickets only)
- [ ] ...

## Answer
(filled in on resolve — wayfinder:* tickets only)
```

`Type:` reuses matt's own wayfinder label vocabulary verbatim for decision-tickets, plus a
fifth value (`implementation`) for to-tickets-style tickets — both kinds share one numbering
sequence and one folder, distinguished only by this field.

**No separate backlog concept.** Considered a `.chief/backlog/tickets/` parking lot for tickets
not yet assigned to a story; rejected as scope creep beyond the original six concepts — a
ticket belongs to exactly one story, full stop.

**Tickets are git-tracked, same as everything else under `.chief/`.** Checked: this repo's own
`.gitignore` has no entry excluding `.chief/` today (goal/contract/report files are already
committed), and `chief-retro` depends on reading git history + past reports for its coverage
check — tickets need the same persistence. Matt's own hesitation about local-markdown tickets
("not recommended: storing this material in the repo tends to lead to accidental persistence" —
`docs/engineering/wayfinder.md`) is about a different problem (ephemeral planning noise
never getting cleaned up in a system with no lifecycle), not about git-tracking `.scratch/`
itself (matt's own `.gitignore` does not exclude it either). Chief's whole value proposition is
persistent project memory — the opposite goal from what that caution is warning against — so
this doesn't apply here.

### 2. Story-vs-wayfinder-map topology

- A **story** is the root container, created first.
- **`/chief-wayfinder`** is optional, explicit-invocation-only (never auto-detected), and can be
  called at any point in a story's life — not only before `/chief-plan` starts. A story can
  pre-exist before wayfinder is invoked on it.
- `/chief-plan`'s Phase 0 surfaces the choice ("grill normally, or use wayfinder?") so the user
  doesn't need to already know `/chief-wayfinder` exists.
- Both wayfinder's decision-tickets and to-tickets-style implementation-tickets live in the
  same story's `_tickets/` store (see "Ticket model").

### 3. Storage backend: full abstraction, local-only implementation, directory name not hardcoded

Adopts matt's pattern of a per-repo pointer/config file that every skill reads instead of
hardcoding a path — but, unlike matt (who ships GitHub/GitLab/local out of the box), v5 ships
**only the local backend**. GitHub/GitLab/other backends are a seam for later, not implemented
now. (When a GitHub backend does eventually land: 1 Chief story ≈ 1 GitHub Issue, per the
naming rationale above — not a GitHub Milestone.)

**The local backend's directory name is itself not hardcoded** — `.chief/` is the *default*,
not a requirement. This is the literal reading of the original ask ("chief จะไม่ fix dir
`.chief`"), not just "which backend" being configurable.

That creates a bootstrap problem the first draft of this doc got wrong: a pointer file that
lives *inside* the directory it's naming can't be found before you already know the directory's
name. The fix (same one matt uses — `docs/agents/issue-tracker.md` lives outside the
configurable `.scratch/`, never inside it): the pointer lives at a **fixed location outside any
configurable directory**.

**`.chief.config.md`** at the repo root (naming convention borrowed from `.eslintrc` /
`.prettierrc`-style tool configs) is that fixed anchor. Its only job, forever, is naming the
storage root — kept deliberately minimal and stable since it has to be readable before anything
else is known:

```markdown
# Chief config

storage-root: .chief/
```

**Two-tier config, local-backend-specific.** Anything else Chief needs to configure that *isn't*
about locating the storage root in the first place belongs in a second file,
`<storage-root>/config.md` (i.e. `.chief/config.md` under the default root) — resolved only
after `.chief.config.md` has already answered "where." This mirrors matt's own two-tier pattern
(a short pointer in `AGENTS.md`/`CLAUDE.md`, full detail in `docs/agents/issue-tracker.md`),
adapted to respect the bootstrap constraint above: nothing may need `<storage-root>/config.md`
to be resolvable before `storage-root` itself is known.

This second tier only makes sense for the local backend — it's a file *inside* a local
directory. `.chief.config.md` at the root is the one thing every backend needs (it answers
"where/what backend," full stop, e.g. a future `backend: github` value instead of
`storage-root:`); a non-local backend wouldn't have a local directory for a second config file
to live inside, and would need its own equivalent, decided when that backend is built.

At v5 scope `<storage-root>/config.md` has nothing to hold yet (there's only one backend) — it
stays uncreated until a real setting needs it, same lazy-creation convention as the rest of
`.chief/`.

Every skill resolves the storage root by checking for `.chief.config.md` first. **Most projects
will never have this file at all**: its absence means "use the default, `.chief/`," so a
project happy with the default goes straight to creating `.chief/config.md` (or nothing, if
there's no setting to store yet) without ever touching the root. `.chief.config.md` only comes
into existence as an escape hatch, the rare case where a project wants the storage root to be
named something other than `.chief/`. This keeps the common case at zero or one file, not two,
while still making the rename possible for the projects that want it — and v4-style projects
with no `.chief.config.md` keep working with no migration step, since absence already means
"default." `/chief-init` (or a new small setup step) explicitly surfaces a "where should
planning artifacts live?" question even though there's only one working answer today — a
deliberate choice to make "not fixed" visible from day one, not just true internally.

### 4. Goal/contract stay two files; gain matt's missing sections

Matt's `to-spec` has two sections Chief's `goal`/`contract` don't: **Testing Decisions** and
**Out of Scope**. Placement, decided by fit rather than by matt's document order:

- **Out of Scope → `_goal/goal.md`** (new `## Out of Scope` subsection). It's the natural
  complement of "what this story delivers" — answerable at the same time as the goal itself,
  no dependency on the contract existing yet.
- **Testing Decisions → `_contract/contract.md`** (new `## Testing Decisions` subsection), not
  goal. Its actual content ("which modules will be tested," "prior art for the tests") needs
  the module/interface shape that Phase 2 (contract) is what determines — writing it during
  Phase 1 (goal) would mean naming modules before they're decided. Phase 1 can still gesture at
  test intent at a high level if useful; the concrete version belongs with the contract.

Goal/contract stay as two files (not merged into one matt-style `spec.md`) specifically to keep
Chief's 2-phase approve-then-continue gate, which matt's single-shot `to-spec` doesn't have.

### 5. Termination condition stays Chief's own

Matt's `implement` explicitly has no completion step ("it ends at the commit and never
touches the work item... close the ticket and reconcile the criteria yourself" —
`docs/engineering/implement.md`). The unreleased `implement-spec` defines "done" as pure
task-graph exhaustion, with no check against any upstream goal or spec. Neither gives
`chief-loop` / `chief-autopilot` what they need: **the termination check — "goal met AND
contract satisfied" — is Chief's own logic and is kept unchanged in v5.**

### 6. `/chief-build` (replaces `builder-agent`, absorbs matt's `implement`)

- New skill, not a call into matt's `/implement` and not a rename of it — no direct reference
  to an unmodified third-party skill file.
- Internal recipe follows matt's 5 beats: TDD at pre-agreed seams → typecheck often → run a
  single test file often → run the full suite once at the end → code review
  (`/chief-review-code`, see below) → commit.
- Everything `builder-agent.md` had that matt's `implement` doesn't — the escalation format,
  the progress-based auto-fix policy, the story-scoping boundary, the commit-message
  convention — is kept, folded into the same skill file.
- **Not an orchestrator.** Scope is deliberately narrow: given one ticket, build it correctly.
  It does not decide what's next and does not check story completion — same self-description
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

Called as the review beat inside `/chief-build`'s recipe, and directly invocable by a human the
same way matt's `/code-review` is.

### 8. All persistent subagents (`.agents/agents/*`) are deprecated

| v4 file | v5 disposition |
|---|---|
| `chief-agent.md` | Deprecated outright — its content duplicates `chief-plan`/`chief-loop`/`chief-autopilot`'s own (more precise) instructions. No replacement identity needed: "the orchestration brain" is just whichever `chief-*` skill is currently running. |
| `builder-agent.md` | Folded into `/chief-build`. |
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
- **No automated `.chief/` migration script.** A story in flight on v4 (a "milestone" there)
  finishes on a pinned v4 checkout; there is no supported path to migrate a half-done v4
  milestone's `_todo.md`/`task-N.md` into v5's ticket shape, or its directory name from
  `milestone-N/` to `story-N/`, mid-flight.
- README version badge, version-history section, and `/chief-upgrade` pin instructions need
  updating to add the v5 entry (there is precedent for deprecating an agent across a version
  bump already — v4's changelog line says "`answer-verifier-agent` replaces deprecated
  `review-plan-agent`").

## Open items (not blocking, need resolving during implementation)

- The subagent-spawn mechanism noted under `/chief-build` (#6 above).
- Full inventory of every doc file that says "milestone" and needs updating to "story"
  (`rules-hierarchy.md`, `directory-structure.md`, `your-first-milestone.md` tutorial —
  possibly renamed to `your-first-story.md`, `template/AGENTS.md`, `README.md`,
  `README.th.md`, `docs/example-chief/`, `docs/manual/reference/agents.md`,
  `docs/manual/reference/skills.md`, `scripts/setup.sh`, `scripts/upgrade.sh`) — not yet
  enumerated exhaustively.

## Non-goals for v5

- GitHub/GitLab/Linear backend implementations (seam only, see "Storage backend").
- A `researcher`/exploration throwaway subagent ahead of `/chief-build` (matt's
  `implement-spec` pattern) — considered and explicitly deferred; scope creep risk against an
  already-large change set.
- Concurrent/parallel ticket execution (matt's `implement-spec` "maximum concurrency" model) —
  Chief's loop stays one-ticket-at-a-time, unchanged from v4.
- A global backlog store for unassigned tickets — considered and rejected; a ticket belongs to
  exactly one story.
