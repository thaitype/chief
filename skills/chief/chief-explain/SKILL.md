---
name: chief-explain
description: Self-contained structural reference for the Chief framework — directory layout, storage-location resolution, the chief-* skill family and what each owns, and the rules for writing `.chief/_rules/` files. For the agent's own understanding, not a human-facing tutorial. Model-invocable — reach for it whenever you need to know how Chief is shaped and don't already know.
---

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
├── AGENTS.md               ← framework + project rules (highest authority) — kept minimal;
│                              everything explanatory lives in skills like this one instead
└── .chief/                 ← or wherever .chief.config.md points, see above
    ├── project.md          ← tech stack, dev commands (written by /chief-init)
    ├── _rules/
    │   ├── _standard/       ← coding standards, architecture constraints
    │   ├── _contract/       ← global API contracts, data models
    │   ├── _goal/           ← long-term direction (spans stories)
    │   └── _verification/   ← test commands, definition of done
    └── story-N/             ← one issue/ticket-sized unit of work (not a "Milestone" — see
        │                       docs/design/v5-ai-workflow.md for why the name changed)
        ├── _map.md           ← only if /chief-wayfinder was used: Destination / Notes /
        │                        Decisions so far / Not yet specified / Out of scope
        ├── _goal/goal.md     ← what this story delivers + Out of Scope
        ├── _contract/contract.md  ← API shapes, data models, constraints + Testing Decisions
        ├── _tickets/         ← decision-tickets (wayfinder) and implementation tickets
        │                        (chief-plan), one flat numbering sequence per story, no
        │                        story-number prefix (the folder already scopes it)
        └── _report/          ← ticket reports, retro output, investigations
```

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
| `/chief-build` | Implementer | Builds ONE ticket: TDD, typecheck, test, `/chief-review-code`, commit | Decide what's next, check story completion |
| `/chief-test` | Verifier | Long-running/integration/UI/API validation, only when explicitly requested | Implement code, patch bugs, run unit tests |
| `/chief-review-code` | Reviewer | Two-axis (Standards + Spec) review of a diff | Decide, implement |
| `/chief-loop`, `/chief-autopilot` | Orchestrator | Works the ticket frontier via `/chief-build`, decides what's next, checks goal+contract satisfied | Implement code directly |
| `/chief-grill` | Deep stress-test | Verified, persistent grill session | Plan, implement |
| `/chief-rule` | Rule capture | Writes a single rule to `_rules/` | Anything outside `_rules/` |
| `/chief-retro` | Retrospective | Coverage check, lessons, proposes rule updates | Modify goal/contract/tickets |
| `/chief-migrate` | Migration | Converts an in-progress v4 milestone into a v5 story | Touch `AGENTS.md`, delete anything without asking |
| `/chief-install`, `/chief-upgrade` | Setup | Install/upgrade `AGENTS.md` | Touch `.chief/` |
| `/setup-agent-behavior` | Setup (opt-in) | Writes general (non-Chief) agent-conduct rules into `AGENTS.md`, on request | Anything automatic |

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
