# AGENTS.md

## Agent Behavior Principles

### 1. Think Before Acting

- Start with the smallest plausible interpretation of the request.
- If uncertain, ask ONE clarifying question — don't assume the big interpretation.
- Surface tradeoffs and push back when a simpler approach exists.
- When confused, name what's unclear and stop. Don't hide confusion behind a plan.

### 2. Simplicity First

- Do the minimum that solves the problem. Nothing speculative.
- If a task can be done in 1-3 commands, do it directly. Don't delegate trivial work to `/chief-build`.
- No features, abstractions, or error handling beyond what was asked.
- If a plan starts needing an options table, pause — you may not have understood the question.

### 3. Surgical Changes

- Touch only what the request requires. Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken. Match existing style.
- Every changed line should trace directly to the user's request.
- Clean up only what YOUR changes made unused. Don't remove pre-existing dead code unless asked.

### 4. Goal-Driven Execution

- Transform vague requests into verifiable goals before starting.
- Define what "done" looks like. Loop until verified.
- For multi-step work, state a brief plan with verification at each step.
- Strong success criteria let agents work independently. Weak criteria require constant clarification.

## User Interaction Rules

- When asking the user a question, use ask_user with ONE short question only.
- When presenting a recap, summary, or review:
  1. Print it as formatted text first (numbered list, table, or markdown block).
  2. Then ask_user ONCE with a short confirmation, e.g. "Proceed?" or "Any changes?"
  3. NEVER put recap content inside ask_user.
- Do NOT ask multiple questions in a row. Make a recommendation, summarize, then confirm once.

---

## Chief Framework

### Storage location

Planning artifacts (project context, stories, rules) live under `.chief/` by default. If
`.chief.config.md` exists at the repo root, it names a different location instead
(`storage-root: <path>`) — check for it before assuming `.chief/`. Most projects never create
this file; its absence means the default. See `/chief-init`.

### Rules Hierarchy

1. **Project Rules** above (highest authority)
2. `.chief/_rules`
3. `.chief/story-X/_goal` (lowest authority)

If rules conflict, higher priority wins. Always.

Each story is self-contained. Only the active story's goal/contract + global `.chief/_rules/`
apply. Previous stories' artifacts are not inherited. To carry forward a decision from a past
story, promote it to `.chief/_rules/`.

---

### Directory Structure

`.chief/` is created lazily — folders and files are added on first need, not pre-scaffolded. The
shape below is the canonical layout that emerges as you use the framework:

```
.chief/
├── project.md           # Created by /chief-init
├── _rules/
│   ├── _standard/       # Coding standards, architecture constraints
│   ├── _contract/       # Data models, API contracts, schemas
│   ├── _goal/           # High-level goals (shared across stories)
│   └── _verification/   # Test commands, build requirements, definition of done
└── story-X/
    ├── _map.md          # Only if /chief-wayfinder was used
    ├── _goal/           # Story goal + Out of Scope
    ├── _contract/       # Story contract + Testing Decisions
    ├── _tickets/         # Decision-tickets and implementation tickets
    └── _report/          # Ticket reports, batch reports, retros, investigations
```

### The `chief-*` skill family

There is no persistent subagent roster in v5 — `/chief-build` and `/chief-test` are skills that
spawn their own throwaway subagents for isolated context when they need it, not registered
agent files.

| Skill | Role | Does | Does NOT |
|-------|------|------|----------|
| `/chief-plan` | Planner | Grill or hand off to `/chief-wayfinder`, write goal + contract, break into tickets | Implement code |
| `/chief-wayfinder` | Fog-charter | Map a story's open decisions as tickets, resolve one at a time | Write goal/contract itself, implement code |
| `/chief-loop`, `/chief-autopilot` | Orchestrator | Work the ticket frontier via `/chief-build`, decide what's next, check goal+contract satisfied | Implement code directly |
| `/chief-build` | Implementer | Build ONE ticket: TDD at seams, typecheck, test, `/chief-review-code`, commit | Decide what's next, check story completion |
| `/chief-test` | Verifier | Integration/UI/API/environment testing, ONLY when explicitly requested | Implement code, patch bugs |
| `/chief-review-code` | Reviewer | Standards + Spec review of a diff, two parallel axes | Decide, implement |

### Responsibility Boundary

- `/chief-build` handles ALL fast, deterministic, local verification: unit tests, type checks,
  lint, build. It MUST run these before committing.
- `/chief-test` handles ONLY slow, non-deterministic, real-world verification: integration
  tests, UI flows, API calls, auth flows, environment-dependent checks.
- `/chief-test` NEVER runs unit tests, lint, build, or reviews code for style.
- `/chief-test` is ONLY triggered when the user explicitly requests it. `/chief-loop` and
  `/chief-autopilot` MUST NOT auto-delegate to it.

### Rules for `.chief/_rules` Files

- MUST be concise, structural, clear
- MUST eliminate ambiguity
- Include small code examples when useful
- Anything unclear may lead to incorrect autonomous decisions

---

## Project Rules

- This repo IS the Chief framework. Sources of truth:
  - Framework rules file: `template/AGENTS.md`
  - Skills: `skills/` (chief, setup)
  - Example `.chief/` layout (reference only, not consumed by install): `docs/example-chief/`
- v5 has no `template/.agents/agents/` subagent roster anymore — `/chief-build`/`/chief-test`
  are skills under `skills/chief/`, not agent files. Don't recreate `.agents/agents/`.
- Product changes (AGENTS.md content, skills) → MUST edit the source-of-truth path first, then
  sync to root if applicable.
- `.chief/` is created lazily at runtime by whichever `chief-*` skill runs first. There is no
  `template/.chief/` to scaffold from.
- Dogfooding-only changes (story plans, tickets, reports) → edit root `.chief/` directly.
- NEVER let root and template drift without explicit reason.

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in
`.chief/project.md`.
