---
name: chief-explain
description: Self-contained structural reference for the Chief framework — directory layout, storage-location resolution, the chief-* skill family and what each owns, and the rules for writing `.chief/_rules/` files. For the agent's own understanding, not a human-facing tutorial. Model-invocable — reach for it whenever you need to know how Chief is shaped and don't already know.
---

**Chief version:** `v5.canary-2.exp` — bumped by hand in this line whenever a new canary/release tag
is cut. This is the only version marker that reliably travels with an install (`npx skills add`
only copies `skills/`, never `docs/` or git history) — read it here if you need to know which
build of Chief is actually running, and treat it as informational only, not a correctness check
(it says nothing about whether a specific fix has landed on top of it).

Reference material about how Chief itself is put together. Read this when you need to know
where something lives, which skill owns a responsibility, or how a mechanism works — not when
the user needs to be taught which skill to reach for (that's `/ask-chief`, a different audience:
a human deciding what to do next, not an agent needing structural facts).

This skill is **self-contained on purpose**: `docs/manual/` in the `thaitype/chief` repository
covers the same ground in more depth for humans browsing GitHub, but that directory is never
installed into a consuming project (only `skills/` is — check
`.claude-plugin/marketplace.json` if in doubt). An agent working in a project that installed
Chief via `npx skills` has no local copy of `docs/manual/` to read, so this skill carries its
own copy of what's operationally necessary rather than pointing at files that won't exist.

---

## Storage location

Planning artifacts (`project.md`, `_rules/`, `story-N/`) live under `.chief/` by default. This
is a default, not a hardcoded requirement.

Resolution order, followed by every `chief-*` skill:

1. Check for `.chief.config.md` at the **repo root** (outside any storage directory — it has
   to be, since a pointer naming the storage directory can't itself live inside a directory
   whose name isn't known yet).
2. **Absent** (the common case — most projects never create this file) → use `.chief/`.
3. **Present** → read its `storage-root:` line and use that path everywhere instead.

A second, optional file, `<storage-root>/config.md` (i.e. `.chief/config.md` by default), holds
settings that aren't about locating the storage root in the first place — nothing needs it yet
at this version, so it usually doesn't exist. This second file only makes sense for a local
filesystem backend; it has no equivalent for a future non-local backend.

## Directory structure

```
project/
├── AGENTS.md               ← optional, entirely the user's own — Project Rules are the
│                              highest authority if this file exists at all; Chief never
│                              creates or writes to it, everything explanatory lives in
│                              skills like this one instead
└── .chief/                 ← or wherever .chief.config.md points, see above
    ├── project.md          ← tech stack, dev commands (written by /chief-init)
    ├── _rules/
    │   ├── _standard/       ← coding standards, architecture constraints
    │   ├── _contract/       ← global API contracts, data models
    │   ├── _goal/           ← long-term direction (spans stories)
    │   └── _verification/   ← test commands, definition of done
    └── story-N/             ← one issue/ticket-sized unit of work (renamed from v4's
        │                       "Milestone" — sized like one tracker issue, not a multi-week
        │                       epic)
        ├── _map.md           ← only if /chief-wayfinder was used: Destination / Notes /
        │                        Decisions so far / Not yet specified / Out of scope
        ├── _goal/            ← what this story delivers, plus Out of Scope
        │   └── *.md            no fixed filename — one file is the common case, more when a
        │                       piece of scope is genuinely distinct (v4's rule); Out of Scope
        │                       defaults to its own file, folded into an existing one only when
        │                       the story is small enough that a separate file is overkill
        ├── _contract/        ← API shapes, data models, constraints, plus Testing Decisions
        │   └── *.md            same shape as `_goal/`: no fixed filename, Testing Decisions
        │                       defaults to its own file, folded in when the story is small
        ├── _tickets/         ← decision-tickets (wayfinder) and implementation tickets
        │                        (chief-plan), one flat numbering sequence per story, no
        │                        story-number prefix (the folder already scopes it)
        └── _report/          ← ticket reports, retro output, investigations
```

Neither bucket has a required filename — a skill reading a story's goal or contract reads every
file in `_goal/`/`_contract/`, never assumes one specific name holds everything.

`.chief/` (or the resolved storage root) is created **lazily** — nothing appears until the
first thing that needs it runs. Don't expect `_rules/` subfolders, `story-N/`, or anything else
to exist ahead of time; check, don't assume.

## The `chief-*` skill family

No persistent subagent roster exists in v5. `/chief-build` and `/chief-test` are skills that
spawn their own throwaway subagents for isolated context when they need it — nothing is
installed separately, nothing needs to be kept in sync with a template.

| Skill | Role | Does | Does NOT |
|---|---|---|---|
| `/chief-init` | Bootstrap | Writes `project.md`, confirms storage location | Plan, build |
| `/chief-wayfinder` | Fog-charter | Maps a story's open decisions as tickets, resolves one at a time | Write goal/contract, implement |
| `/chief-plan` | Planner | Grill or hand off to wayfinder, writes goal + contract, breaks into tickets | Implement code |
| `/chief-build` | Implementer | Builds ONE ticket, standard mode (default) or strict mode: TDD, typecheck, test, `/chief-review-code`, commit | Decide what's next, check story completion |
| `/chief-test` | Verifier | Long-running/integration/UI/API validation, only when explicitly requested | Implement code, patch bugs, run unit tests |
| `/chief-review-code` | Reviewer | Two-axis (Standards + Spec) review of a diff | Decide, implement |
| `/chief-loop` (standard default, `strict` arg; sequential default, `parallel`/`parallel:<N>` arg — each in its own git worktree), `/chief-autopilot` (always standard, always sequential) | Orchestrator | Works the ticket frontier via `/chief-build`, decides what's next, checks goal+contract satisfied | Implement code directly |
| `/chief-grill` | Deep stress-test | Verified, persistent grill session | Plan, implement |
| `/chief-rule` | Rule capture | Writes a single rule to `_rules/` | Anything outside `_rules/` |
| `/chief-retro` | Retrospective | Coverage check, lessons, proposes rule updates | Modify goal/contract/tickets |
| `/chief-migrate` | Migration | Converts an in-progress v4 milestone into a v5 story | Touch `AGENTS.md`, delete anything without asking |
| `/setup-agent-behavior` | Setup (opt-in) | Writes general (non-Chief) agent-conduct rules into `AGENTS.md`, on request | Anything automatic |

**`standard` vs `strict` (chief-build's two modes, referenced above and by chief-loop/
chief-autopilot):** `standard` restores v4 builder-agent's process — no mandatory TDD or
`/chief-review-code` per ticket. `strict` is v5's original per-ticket rigor: TDD at pre-agreed
seams plus a mandatory `/chief-review-code` pass. Neither mode skips ordinary local verification
(typecheck, tests) — the only difference is the TDD/review mandate, not speed. `chief-build`
itself defaults to strict when invoked directly; `chief-loop` defaults to standard (with a
`strict` argument to opt in); `chief-autopilot` always uses standard, with no argument to change
it.

There's no install/upgrade skill — Chief needs nothing written to `AGENTS.md` to work. Getting
the skills at all (`npx skills add thaitype/chief` or equivalent) is the only setup step;
`/chief-init` is the natural first thing to run afterward, but nothing enforces that order.

Responsibility boundary worth calling out explicitly, since it's the one most often violated in
practice: **`/chief-build` handles all fast, deterministic, local verification** (unit tests,
type checks, lint, build) — it must run these before committing. **`/chief-test` handles only
slow, non-deterministic, real-world verification**, and only when the user explicitly asks for
it; `/chief-loop`/`/chief-autopilot` must never auto-delegate to it.

## Rules for `.chief/_rules/` files

- Must be concise, structural, and unambiguous — anything unclear can lead to a wrong
  autonomous decision downstream.
- Small code examples are welcome where they clarify.
- Written as plain markdown, no frontmatter — `/chief-rule` follows this convention, so should
  any manual edit.
