# AGENTS.md

## Agent Behavior Principles

### 1. Think Before Acting

- Start with the smallest plausible interpretation of the request.
- If uncertain, ask ONE clarifying question — don't assume the big interpretation.
- Surface tradeoffs and push back when a simpler approach exists.
- When confused, name what's unclear and stop. Don't hide confusion behind a plan.

### 2. Simplicity First

- Do the minimum that solves the problem. Nothing speculative.
- If a task can be done in 1-3 commands, do it directly. Don't delegate trivial work to builder-agent.
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

## Chief Agent Framework

## Rules Hierarchy

1. **Project Rules** above (highest authority)
2. `.chief/_rules`
3. `.chief/milestone-X/_goal` (lowest authority)

If rules conflict, higher priority wins. Always.

Each milestone is self-contained. Only the active milestone's goals/contracts + global `.chief/_rules/` apply. Previous milestone artifacts are not inherited. To carry forward a decision from a past milestone, promote it to `.chief/_rules/`.

---

### Directory Structure

`.chief/` is created lazily — folders and files are added on first need, not pre-scaffolded. The shape below is the canonical layout that emerges as you use the framework:

```
.chief/
├── project.md           # Created by /chief-init
├── _rules/
│   ├── _standard/       # Coding standards, architecture constraints
│   ├── _contract/       # Data models, API contracts, schemas
│   ├── _goal/           # High-level goals (shared across milestones)
│   └── _verification/   # Test commands, build requirements, definition of done
└── milestone-X/
    ├── _goal/           # Milestone-specific goals
    ├── _contract/       # Milestone-specific contracts
    ├── _plan/           # _todo.md + task-N.md specs
    └── _report/         # Reports, investigations, task outputs
```

### 3-Agent Architecture

| Agent | Role | Does | Does NOT |
|-------|------|------|----------|
| **Chief** | Planner/Orchestrator | Plan, delegate, decide, update todo | Implement code |
| **Builder** | Implementer | Code, unit test, type/lint fix, commit | Integration test, architecture decisions |
| **Tester** | Verifier | Integration/UI/API/environment testing | Implement code, patch bugs |

### Responsibility Boundary

- **Builder** handles ALL fast, deterministic, local verification: unit tests, type checks, lint, build. Builder MUST run these before committing.
- **Tester** handles ONLY slow, non-deterministic, real-world verification: integration tests, UI flows, API calls, auth flows, environment-dependent checks.
- Tester NEVER runs unit tests, lint, build, or reads source files for code review.
- Tester is ONLY triggered when the user explicitly requests it. Chief MUST NOT auto-delegate to tester.
- Tester is injected into the cycle only when the user requests real-world validation.

### Rules for `.chief/_rules` Files

- MUST be concise, structural, clear
- MUST eliminate ambiguity
- Include small code examples when useful
- Anything unclear may lead to incorrect autonomous decisions

---

## Project Rules

<!-- WRITE YOUR PROJECT-SPECIFIC RULES HERE — highest authority -->
<!-- More details on project configuration in .chief/project.md -->

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in `.chief/project.md`.
