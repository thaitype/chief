# Deep-Interview Skill — Design Decisions

Date: 2026-04-22

## Context

Designing a `deep-interview` skill for the Chief Agent Framework, inspired by [oh-my-codex/deep-interview](https://github.com/Yeachan-Heo/oh-my-codex/blob/main/skills/deep-interview/SKILL.md). The goal is a Socratic interview with quantitative ambiguity scoring that produces execution-ready specs.

## Decisions Made

### 1. Separate from grill-me
- Keep both skills. Grill-me = lightweight freeform. Deep-interview = rigorous with scoring.
- They serve different purposes and different situations.

### 2. Full ambiguity scoring
- Score clarity on weighted dimensions per round.
- Greenfield: `ambiguity = 1 - (intent x 0.30 + outcome x 0.25 + scope x 0.20 + constraints x 0.15 + success x 0.10)`
- Brownfield: adds Context Clarity at 0.10, redistributed from other weights.
- Show score each round transparently.

### 3. Depth profiles (same as OMX)
- Quick: 5 rounds, threshold <= 0.30
- Standard (default): 12 rounds, threshold <= 0.20
- Deep: 20 rounds, threshold <= 0.15

### 4. Challenge modes — all three
- **Contrarian** (round 2+): challenge core assumptions
- **Simplifier** (round 4+): probe minimal viable scope
- **Ontologist** (round 5+, ambiguity > 0.25): force root-cause reframing

### 5. Mandatory readiness gates
- Non-goals must be explicit before crystallizing.
- Decision Boundaries (what AI can decide without asking) must be explicit.

### 6. Output location
- Spec + transcript → `.chief/<milestone>/_report/deep-interview-<slug>.md`
- NOT directly to `_goal/` or `_contract/`. User promotes on approval.

### 7. Execution bridge options
1. `/chief-plan` — plan with review gates
2. `/chief-autopilot` — autonomous execution
3. Write goals/contracts only — promote spec, stop there
4. Refine further — continue interviewing

### 8. State management — file-based, no runtime tooling
- State persisted as JSON: `.chief/<milestone>/_report/deep-interview-state.json`
- AI reads/writes directly. No Python script or MCP server.
- Reason: framework has zero runtime dependencies (just markdown). Adding Python/Node tooling would break that principle.
- If AI consistently corrupts state in practice, revisit and add tooling then.

### 9. OMX-specific features NOT adopted
- `omx question` (structured questioning tool) — use normal conversation instead
- `state_write` / `state_read` (MCP state server) — use file-based JSON instead
- `.omx/` directories — use `.chief/<milestone>/_report/` instead
- Autoresearch mode — not applicable to this framework
- `omx explore` — use normal codebase exploration instead

## Open — Not Yet Implemented
- The actual SKILL.md file has not been written yet.
- chief-plan Phase 0 still uses grill-me, not deep-interview. Both remain available as separate tools.
