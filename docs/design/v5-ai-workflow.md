# Chief v5 — AI Workflow Redesign

**Status:** Implemented on this branch, both rounds described below (the original pipeline
redesign, and the "Round 2" section added afterward). Not yet merged to `main` or released —
`release/v4` still needs cutting first, per "Versioning and migration." This doc remains the
design record of *why*, written during and after the grill-design sessions that produced it.

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

**File shape** (`.chief/story-N/_tickets/<seq>-<slug>.md`, numbered per-story from 1, e.g.
`1-user-listing-schema.md` for this story's first ticket — **no story-number prefix**: the
folder (`.chief/story-N/_tickets/`) already scopes it, so repeating the story number in the
filename would be redundant. An earlier draft of this doc did prefix it (`<story>-<seq>`,
carried over from a `.chief/backlog/` concept that would have let a ticket exist before being
assigned to a story); once backlog was considered and rejected — see below — nothing produces
a ticket that isn't already inside a story folder, so the prefix's only reason to exist went
with it):

```markdown
# 1: <ticket title>

Type: wayfinder:research | wayfinder:prototype | wayfinder:grilling | wayfinder:task | implementation
Status: open | claimed | resolved
Blocked by: 2, 5  (or "None (can start immediately)")

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
sequence and one folder, distinguished only by this field. Matt's own local-markdown convention
doesn't have an equivalent fifth value (his to-tickets template carries no `Type:` field at
all — presence vs. absence of the field is what distinguishes his two ticket kinds); an
`implementation` value was considered and rejected as a closer copy of that presence/absence
convention, then explicitly brought back, since it's more robust for anything reading the file
(no special-case "field is just missing" handling) at the cost of one more line per ticket.

**`wayfinder:task` vs. `implementation` — worth being explicit about, since both are "do work"
tickets and look similar at a glance:**

| | `wayfinder:task` | `implementation` |
|---|---|---|
| When | Phase 0, before the goal/contract can even be written | Phase 3 onward, after goal/contract are approved |
| Unblocks | A *decision* (another ticket) | The story's *delivery* (the goal itself) |
| Resolves into | A recorded fact in `## Answer` (credentials location, a URL, a row count — something now known) | A commit, via `/chief-build` |
| Who runs it | Inline within `/chief-wayfinder` (agent alone if AFK, or a checklist handed to the human if HITL) | `/chief-build` only |
| Counts toward "story done"? | No — it only clears fog | Yes — it's part of what "goal met AND contract satisfied" checks |

Example: "sign up for a trial of service X to judge whether its API fits" is `wayfinder:task`
(unblocks the *decision* of which service to use, before the contract can name it). "Implement
the S3 upload handler per the contract" is `implementation` (delivers what was already decided).

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

## Future ideas (not v5 scope, not decided, just captured)

- **`/chief-triage`** — matt's `/triage` handles issues *he didn't create*: raw external bug
  reports and feature requests landing in the same tracker as his own planned work, run through
  a category × state machine (`needs-triage`/`needs-info`/`ready-for-agent`/`ready-for-human`/
  `wontfix`) that Chief has no equivalent of today, deliberately — every Chief ticket currently
  comes from `/chief-plan` or `/chief-wayfinder`, never from an external reporter. If Chief ever
  wants to ingest bug reports filed by a project's own end-users (not bugs in Chief itself),
  this is the shape that would need designing. Chief's `Status:` vocabulary
  (`open`/`claimed`/`resolved`) deliberately doesn't borrow matt's triage-state vocabulary today
  because there's no external-intake path for it to describe — revisit this decision together
  if `/chief-triage` ever gets built, since the two are linked.

## Round 2: chief-migrate, chief-explain, ask-chief, and an AGENTS.md slimdown

A second grill-design session, after the skills above already shipped, added four more skills
and restructured `AGENTS.md`. Decisions:

### `chief-migrate`

Optional companion to `chief-upgrade`, which handles `AGENTS.md` and detects the v4→v5 jump but
deliberately never touches `.chief/milestone-N/` content (see "Versioning and migration"
above). This skill is the opt-in path for whoever wants that content actually converted.

- Only migrates **open** milestones (closed = has `_report/retro-milestone.md`, or every
  `_plan/_todo.md` item checked `[x]`) — closed ones are historical record, migrating them has
  no value.
- `_todo.md` items + `task-N.md` specs → tickets **1:1**, no invented blocking edges (a flat
  checklist's order is priority, not a dependency graph — guessing wrong is worse than not
  guessing). Tagged `Migrated-from:` so they stay distinguishable from natively-planned tickets.
- Read-and-plan first, write additively (new `story-N/` alongside the untouched
  `milestone-N/`), then ask **separately** whether to delete the old milestone directory — never
  bundled into the same approval as the migration itself.

### `chief-explain` (was `chief-manual`) and `ask-chief`

Two skills replacing what used to live in `AGENTS.md`, split by **audience**, not just content:

- **`chief-explain`** — agent-facing structural reference (directory layout, storage-location
  resolution, the `chief-*` skill family, `_rules/` writing rules). Consulted by the agent for
  its own understanding.
- **`ask-chief`** — human-facing router modeled on `mattpocock/skills`' `ask-matt`, `disable-
  model-invocation: true`. Teaches a person which skill fits their situation; defers to
  `chief-explain` for structural depth rather than re-describing each skill.

Both had to be **self-contained**, not thin pointers into `docs/manual/**` — checked
`.claude-plugin/marketplace.json` and confirmed only `skills/` ships to a consuming project via
`npx skills`/the plugin path, never `docs/`. A pointer to files that don't exist on the
installing project's disk would be silently broken for every real user. `docs/manual/**` stays
the deeper reference for humans browsing the `thaitype/chief` repo on GitHub; the two skills
above duplicate the operationally-necessary subset of it on purpose, accepting the drift risk
as the cost of the audience split.

`chief-explain` is **model-invocable** (unlike almost everything else in this design) because
it replaces content that used to auto-load into every session via `AGENTS.md` — an agent needs
to be able to reach for it unprompted, the same way it used to just *know* this. `ask-chief`
stays `disable-model-invocation: true` like `ask-matt`, since it answers a question only a
confused *human* asks.

### `AGENTS.md` slimdown

Everything that used to live in `AGENTS.md` beyond Project Rules got redistributed by asking,
for each piece, "does an agent need this every session, or only sometimes?":

- **Storage location** → became a one-line pointer-check added to the top of **every**
  individual `chief-*` skill instead of one central explanation — verified this matches matt's
  own pattern exactly (`to-spec`, `to-tickets`, `code-review`, `wayfinder` each carry their own
  "the tracker should have been provided to you..." line rather than relying on a shared doc).
- **Rules Hierarchy** and **Responsibility Boundary** → dropped from `AGENTS.md` entirely,
  confirmed already duplicated inside individual skills' own "Rules" sections (chief-plan/loop/
  autopilot already state the hierarchy; chief-build/chief-test already state their own scope
  boundary) — nothing was lost by removing the redundant central copy.
- **Directory Structure diagram**, the **skill family table**, and **"Rules for `.chief/_rules`
  files"** → moved into `chief-explain` as on-demand reference, since none of them are things an
  agent needs to have memorized to avoid acting incorrectly.
- **Agent Behavior Principles** and **User Interaction Rules** (general agent conduct, not
  Chief-specific at all) → moved to a **new opt-in setup skill**, `setup-agent-behavior`
  (`skills/setup/`, no `chief-` prefix since the content isn't Chief-specific). Unlike
  `chief-explain`'s on-demand-reference model, this content is meant to be *binding every
  session* if a project wants it — which only a write into `AGENTS.md` itself can actually
  guarantee, not a reference skill. So `setup-agent-behavior` writes the block into `AGENTS.md`
  on request (show-then-confirm, same discipline as `chief-upgrade`/`chief-install`), making it
  opt-in but persistent once installed, rather than either always-baked-in (the old v4 default)
  or purely ephemeral (what a reference-only skill would give).

Net result: `AGENTS.md` (root and template) shrinks to a two-line `<!-- chief-framework:begin
-->` marker block pointing at `/chief-explain` and `/ask-chief`, plus the user's own `## Project
Rules` and the `.chief/project.md` pointer.

### `scripts/setup.sh` retired

Reconsidered separately, once `AGENTS.md`'s only remaining job became a small, judgment-
sensitive merge (don't clobber a file that might have unrelated pre-existing content). That
operation fits an agent's diff-present-confirm-write loop better than a script — the same
pattern `chief-upgrade` already used for updates. The CI/non-agentic-installation justification
considered earlier in this document for keeping the script turned out not to reflect an actual
intended use case; once that was withdrawn, nothing remained that a script did better than
`chief-install` doing the same three steps directly. `chief-install` now clones the target
version, presents what would be written, confirms, and writes — no shelling out.

### Ticket ID format correction

While reviewing the ticket template above for this round's work, caught and fixed a leftover
inconsistency: the `<story>-<seq>` ID prefix (e.g. `1-3`) existed only to survive a ticket
being "promoted" out of a `.chief/backlog/` store that was itself considered and rejected
earlier in this document. Once backlog was off the table, nothing ever produces a ticket
outside its story's own `_tickets/` folder, so the prefix had no remaining purpose — every
example, template, and cross-reference in this doc and the shipped skills now uses a plain
per-story sequence (`1`, `2`, `3`...) instead.

### `Type: implementation` reconsidered, kept

Briefly reconsidered dropping the `implementation` value from `Type:` entirely (mirroring
matt's own local convention more closely: his to-tickets template carries no `Type:` field at
all, relying on the field's *absence* to mean "implementation ticket" rather than an explicit
value matt's vocabulary has no equivalent for) and even tried a physical folder split
(`_tickets/decision/` vs `_tickets/build/`) to avoid needing a field at all — checked matt's
actual local-tracker convention directly and found he does neither: `map.md`/`spec.md` sit
outside a single shared `issues/` folder that both ticket kinds share, one numbering sequence,
disambiguated by field presence/absence. Considered adopting that presence/absence mechanism
for Chief too, then explicitly kept the explicit `implementation` value instead, for robustness
(nothing reading a ticket file needs special-case "the field is just missing" handling) at the
cost of one extra line per implementation ticket.

## Round 2 follow-up: `chief-migrate-to-v5` renamed `chief-migrate`

Renamed shortly after round 2 shipped, on the observation that the skill's *name* shouldn't
need to change every time a future version needs the same kind of migration, even though its
*content* genuinely will. This mirrors `chief-upgrade`'s own naming (also not version-suffixed)
but for a different underlying reason: `chief-upgrade`'s mechanism (diff/merge one file) is
identical in kind across any version pair, so a version-agnostic name reflects a truly
version-agnostic operation. `chief-migrate`'s mechanism is not — its Steps are hardcoded to the
v4→v5 shape change specifically, and a hypothetical v5→v6 shape change would need those Steps
**rewritten**, not extended with a new case. The rename buys a stable name users don't have to
relearn, not reusable logic; a scope note was added inside the skill file itself saying so
explicitly, plus a pointer to `git log -p` on the file as the actual historical record of how
past migrations worked — deliberately not a separately maintained changelog/reference-file
system, which would just duplicate what git history already tracks for free, with more risk of
drifting from what the code actually did.

The skill's `description` field was written fully version-agnostic too, once a first draft
was caught still leaking version-specific vocabulary two different ways: first by literally
naming "v4"/"v5", then — after removing the version numbers — by still saying "converts old
task-tracking into **tickets**," where "tickets" is itself v5-specific terminology (v4 called
the same concept a todo list). The final description names neither a version nor a
vocabulary term newer than "an old `.chief/` layout" / "the current one," and says outright
that it's deliberately vague, pointing to the skill's own Steps for the concrete, current-only
specifics.

## Round 2 follow-up: `chief-install` and `chief-upgrade` removed entirely

Removed, not merged — a step further than the `chief-migrate` rename above. The trigger:
noticing that `setup-agent-behavior` already handles "install this block, or update it if
already present" as **one** unified skill, while `chief-install`/`chief-upgrade` did the
structurally identical operation (diff/present/confirm/write a named block in `AGENTS.md`) as
**two**. That inconsistency was the opening; the actual justification for removing both outright
rather than merging them into one came from re-examining what either skill still did, now that
the `.agents/agents/` subagent roster (their original reason for existing, and the bulk of
their complexity — model placeholders, symlink farms, per-agent integration files) was already
gone:

1. **Writing the "Chief Framework" pointer block into `AGENTS.md`.** Checked whether this
   still carried real value and found it didn't: `chief-explain` and `ask-chief` are already
   visible to an agent the moment their skill files are installed (their own `description:`
   fields surface in the skill catalog), and `chief-explain` is model-invocable besides — an
   agent can reach for it on its own steam. The block was pointing at something the agent
   already knew about by other means.
2. **Symlinking `CLAUDE.md` → `AGENTS.md` for Claude Code.** The one piece with a genuine,
   non-redundant reason to exist (Claude Code reads `CLAUDE.md` specifically) — but skills
   themselves don't depend on `AGENTS.md`/`CLAUDE.md` existing at all to be invocable, so this
   only ever mattered for surfacing a user's *own* Project Rules to that specific agent.
   Explicitly chosen **not** to relocate this into `chief-init` or anywhere else — the user's
   call, accepting that Claude Code users who want this now set up the symlink themselves.
3. **Detecting a pre-v5 install and explaining the v4→v5 breaking change.** With the
   subagent-roster cleanup gone, a leftover `.agents/agents/chief-agent.md` is inert dead
   weight, not something that breaks anything by existing — proactive agent-driven detection
   stopped pulling its weight over just documenting the transition
   (`docs/manual/how-to/upgrade.md`, "Upgrading from v4") for a human to read if they hit it.

With all three either redundant or explicitly not relocated, no code remained for either skill
to justify keeping. `template/` (which existed solely to be copied by the now-removed
`chief-install`) was deleted along with it — `template/AGENTS.md` had no remaining reader.
"Upgrading" collapses to the one thing that was always separate from either skill anyway:
refreshing skill files via `npx skills add`, which was already idempotent and version-pinnable
without any Chief-specific skill wrapping it.
