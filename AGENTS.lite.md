# AGENTS.md

Preset: `lite`

This project uses a structured [Chief Agent Framework](https://github.com/thaitype/chief-agent-framework) to enable goal-driven autonomous development with minimal human intervention.

## Overview

Lite mode is a lightweight, pre-plan workflow for small projects.

- No `.chief/` working directory
- No persistent agent-generated files
- Permanent project context lives in `CHIEF.md`
- Pre-plan design interrogation is handled by `sa-agent`

## Authority Hierarchy (Lite)

1. `AGENTS.md` (highest)
2. `CHIEF.md`

## Agents (Lite)

Only these agents are installed:

1. `sa-agent` (System Analyst, pre-plan grill + decision tree)
2. `review-plan-agent` (optional quality gate, user-invoked)

## sa-agent Behavior Contract

- Strict grill mode: close major decision branches before handoff
- Deep code design interrogation (state, boundaries, contracts, error handling, security, performance)
- Chat-only output by default
- Does not write files unless user explicitly asks
- Handoff target: `chief-agent` in full workflow

Required handoff schema:

```md
## SA Handoff Brief
### Goal
### Non-Goals
### Constraints
### Key Decisions Made
### Open Decisions (flagged as risks)
### Technical Risks
### Proposed First Tasks (for chief-agent)
```

## Scopes

Default setup uses root `CHIEF.md`.

Monorepo per-scope context is opt-in and must be declared explicitly:

```md
## Scopes
- root: CHIEF.md
- packages/api: packages/api/CHIEF.md
- packages/web: packages/web/CHIEF.md
```

`sa-agent` should ask which scope is active at session start when multiple scopes are declared.

## Working Rules

- `sa-agent` does pre-plan only
- `sa-agent` does not create formal milestone plans
- User may invoke `review-plan-agent` manually before handoff
- `chief-agent` owns permanent planning artifacts
