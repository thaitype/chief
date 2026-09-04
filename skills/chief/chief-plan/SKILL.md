---
name: chief-plan
description: Plan a new story or extend an existing one step-by-step with review gates. Starts with a choice between a normal grill and /chief-wayfinder, then walks through goal → contract → tickets, pausing for user approval at each step.
---

You are planning a **story** — Chief's unit of work, sized like a single issue/ticket in any
tracker (see `docs/design/v5-ai-workflow.md` for why it's called "story," not "milestone").
Follow this process strictly, one phase at a time. **Never skip ahead.**

---

## Before You Start: New vs Existing Story

Determine whether you are:

- **Creating a new story** — no existing `_goal/`, `_contract/`, or `_tickets/` files exist yet.
- **Extending an existing story** — files already exist in the story directory.

If extending an existing story:
1. Read all existing `_goal/`, `_contract/`, `_tickets/`, and `_map.md` (if present) first.
2. During each phase, decide whether the new content is:
   - **Partial overlap** with an existing file → **update** that file (add/modify sections).
   - **Different scope** from all existing files → **create a new file** alongside existing ones.
3. After writing, verify there are **no conflicts** between the new and existing content within
   the same bucket. If a conflict exists, resolve it before presenting to the user.
4. Verify the new content **respects the rules hierarchy**: `AGENTS.md` > `.chief/_rules` >
   story goal/contract. If the new content would contradict a higher-level rule, flag it and do
   not write it.

---

## Phase 0: Grill or Wayfinder

**NEVER SKIP THIS PHASE.** Even if goals or contracts already exist, resolve this phase first —
existing files may contain outdated or wrong assumptions that only surface through questioning.

**First, ask the user one question:**

> This story's fog — grill it normally, or use `/chief-wayfinder` to map it out first?

This is the discovery surface for `/chief-wayfinder` — the user doesn't need to already know it
exists. Recommend the normal grill by default; suggest wayfinder if the user's opening
description already sounds like it spans multiple unresolved design decisions or needs
research/prototyping before a goal can even be stated.

- **If the user picks wayfinder** → hand off to `/chief-wayfinder` on this story (creating the
  story directory first if it doesn't exist yet). When it returns control (fog cleared, map's
  frontier and "Not yet specified" both empty), read `.chief/story-N/_map.md`'s Decisions so
  far and continue below, grilling **only** what the map didn't already resolve.
- **If the user picks a normal grill** → run a grill-design session directly:
  - Interview the user relentlessly about every aspect of this story until you reach a shared
    understanding.
  - Walk down each branch of the design tree, resolving dependencies between decisions
    one-by-one.
  - For each question, provide your recommended answer.
  - Ask the questions one at a time.
  - If a question can be answered by exploring the codebase, explore the codebase instead.

When extending an existing story, include questions about:
- How the new work relates to existing goals and contracts.
- Whether any existing goals or contracts need revision.
- Whether existing tickets are affected or should be re-prioritized.

When Phase 0 is complete (either path), summarize the key decisions and confirm with the user
before moving on.

---

## Phase 1: Review and Write the Goal

**NEVER SKIP THIS PHASE.** Even if `_goal/goal.md` already exists, present it to the user for
review and approval before moving to the contract.

Based on Phase 0, write or update `.chief/story-N/_goal/goal.md`. Structure:

```markdown
# Goal

<what this story delivers, from the user's perspective>

## Out of Scope

<what this story deliberately does not do — the natural complement of what it delivers; state
this alongside the goal, it doesn't need the contract to exist first>
```

If a goal file already exists:
- Read it and verify it still matches the decisions from Phase 0.
- If Phase 0 revealed it's wrong or incomplete, update it now.
- Present both existing and new/modified content to the user.

If extending: update the existing file when scope overlaps; create a new file when scope is
distinct. Verify no goal contradicts another goal in the same story, and none contradicts
`.chief/_rules/_goal/` or `AGENTS.md`.

**STOP.** Present the goal (new and modified parts) to the user. Highlight what changed vs what
already existed. Wait for explicit approval before proceeding.

---

## Phase 2: Write the Contract

Write or update `.chief/story-N/_contract/contract.md`. Structure:

```markdown
# Contract

<API shapes, data models, constraints>

## Testing Decisions

<what makes a good test for this story (test external behaviour, not implementation details),
which modules/seams will be tested, prior art for the tests elsewhere in the codebase — this
section needs the module/interface shape above to already be decided, which is why it lives
here and not in the goal>
```

If extending: update existing files when scope overlaps (e.g. adding fields to an existing
schema); create new files when scope is distinct (e.g. a new endpoint). Verify no contract
contradicts another contract in the same story, and none contradicts `.chief/_rules/_contract/`
or `AGENTS.md`.

**STOP.** Present the contract (new and modified parts) to the user. Highlight what changed vs
what already existed. Wait for explicit approval before proceeding.

Goal and contract stay two files with two gates deliberately — this is what lets the user
approve *what* before committing to *how*, which a single merged spec document wouldn't give.

---

## Phase 3: Break Into Tickets

Write vertical-slice tickets into `.chief/story-N/_tickets/`, replacing what used to be a flat
`_plan/_todo.md`. See `docs/design/v5-ai-workflow.md` ("Ticket model") for the file shape —
briefly:

- Each ticket is a **tracer-bullet vertical slice**: a narrow but complete path through every
  layer the change touches (schema, API, UI, tests), demoable/verifiable on its own, sized to
  fit one fresh context window (one `/chief-build` run).
- Each ticket declares its **blocking edges** (`Blocked by: <id>, <id>` or "None") — the other
  tickets that must resolve before it can start.
- File: `.chief/story-N/_tickets/<seq>-<slug>.md`, `Type: implementation`, `Status: open`,
  numbered continuing from any existing tickets in the same story (including `wayfinder:*`
  decision-tickets from Phase 0 — one shared sequence, not restarted per type). No story-number
  prefix: the folder already scopes it to this story.
- **Wide refactors are the exception to vertical slicing.** A wide refactor (rename a column,
  retype a shared symbol) has a blast radius that fans across the whole codebase — no vertical
  slice can land green. Sequence it as **expand → migrate (batched by blast radius, each batch
  its own ticket, blocked by expand) → contract**, so CI stays green batch to batch.

If extending: only write tickets for newly added scope. If a new ticket modifies behavior an
existing ticket already covers, reference that ticket and explain how it differs.

**STOP.** Present the proposed tickets as a numbered list — title, blocked-by, what it delivers
— to the user. Ask: does the granularity feel right (too coarse/fine)? Are the blocking edges
correct? Should any be merged or split? Iterate until approved. Wait for explicit approval
before delegating to `/chief-build`.

---

## Conflict Resolution Rules

At every phase, before presenting to the user, verify:

1. **Intra-bucket consistency** — no two files within the same bucket (`_goal/`, `_contract/`,
   `_tickets/`) contradict each other.
2. **Cross-bucket consistency** — goal, contract, and tickets align (e.g. a ticket doesn't
   reference a contract field that doesn't exist).
3. **Hierarchy compliance** — nothing contradicts a higher-level rule: `AGENTS.md` overrides
   everything; `.chief/_rules/**` overrides story-level content; the story goal is the lowest
   authority.

If a conflict is detected: flag it explicitly with both sides, propose a resolution, and do not
proceed until it's resolved.

---

## Backtrack Rule

If user feedback during a later phase reveals an earlier phase's output is wrong or incomplete,
go back and fix the earlier phase first. Do NOT patch the current phase to work around a broken
earlier one.

Examples:
- Contract review reveals a goal assumption is wrong → go back to Phase 1, fix the goal, get
  approval, then return to Phase 2.
- Ticket review reveals the contract is missing a field → go back to Phase 2, fix the contract,
  get approval, then return to Phase 3.

The phase order is strict in both directions: forward (never skip ahead) and backward (always
fix upstream first).

---

## General Rules

- Follow the rules hierarchy: `AGENTS.md` > `.chief/_rules` > story goal.
- If the user rejects or modifies anything at a gate, revise before proceeding.
- Do not delegate to `/chief-build` or `/chief-test` during this skill. This skill is planning
  only.
- This skill never writes code and never spawns a build subagent — that's `/chief-build`'s job,
  invoked afterward by the user, `/chief-loop`, or `/chief-autopilot`.
