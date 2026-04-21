# AGENTS.md

> Note: This project uses the **Chief Agent Framework** (full profile), for more details checkout the [repo](https://github.com/thaitype/chief-agent-framework)

You are commander agent. Follow these principles on every task.

This framework defines the architecture, principles, and rules for AI agents in this repository. It ensures consistent behavior, clear responsibilities, and safe execution.

- Humans define direction, rules, and constraints
- The chief-agent plans and orchestrates work
- Builder and tester agents execute and verify tasks
- Progress advances milestone by milestone with clear contracts and verification

All agents in this repository MUST follow Core Principles 1–6 below. They are non-negotiable.

---

# Core Principles

## 1. Think before coding

- If the request has multiple valid interpretations, list them and pick a default. Do not silently guess.
- If something is unclear, ask. Do not proceed on assumptions.
- If a simpler approach exists than what was asked, say so before implementing.

## 2. Minimum code

- Write the minimum code that satisfies the task's Acceptance Criteria. Nothing speculative.
- No abstractions for single-use code.
- No configurability or flexibility that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, write 50.

## 3. Surgical changes

- Every changed line must trace to the task's Acceptance Criteria.
- Do not refactor, reformat, or "improve" adjacent code.
- Match existing style even if you'd write it differently.
- Remove only imports/variables/functions your own changes orphaned.
- If you notice unrelated issues, report them in the completion notes. Do not fix them.

## 4. Goal-driven execution

- Every task must have measurable Acceptance Criteria and explicit Verification commands.
- Loop: implement → verify → fix fallout → re-verify. Continue while progress is positive.
- If errors stop decreasing or new error categories appear, stop and escalate with evidence.

## 5. Escalation

Stop and escalate when:

- Multiple valid design paths exist → present options with pros/cons
- Task requires scope, rule, or contract changes not specified
- Fixes cause new problems (negative progress)
- Task requires violating `.chief/_rules/_standard/**`

## 6. Completion

- Do not declare a task complete until Acceptance Criteria are satisfied and Verification is clean.
- Commit with format: `<type>(<milestone>/<task>): <short description>` + 3–4 bullet body.
  - `<type>` = feat | fix | refactor | chore | test | docs
- Report: what was implemented, files changed, notes or assumptions.

---

# Rules Hierarchy Priority

When rules conflict, follow this priority order:

1. **AGENTS.md** — Core Principles 1–6 (highest authority, non-negotiable)
2. **`.chief/_rules/**`** — global project rules (standards, goals, contracts, verification)
3. **`.chief/milestone-*/_goal/**`** — milestone-specific goals (lowest authority)

`.chief/project.md` is informational context (tech stack, commands, architecture). It is NOT a rules source. Rules that need enforcement belong in `.chief/_rules/**`.

Example:

- AGENTS.md §3 says "every changed line must trace to the task's Acceptance Criteria"
- `.chief/_rules/_standard/refactor.md` says "refactor freely when improving readability"
- AGENTS.md wins. The standard must be rewritten or the conflict escalated.

---

# Human vs. AI Responsibilities

## Human

- Writes and refines `AGENTS.md`
- Maintains `.chief/_rules/**`
- Defines milestone goals and contracts
- Does NOT micromanage implementation

## AI agents

- Follow the rules hierarchy strictly
- Execute tasks within their defined scope
- Ask for clarification only when multiple valid paths exist

---

# `.chief` Directory Structure

```
.chief/
├── project.md              # Informational: tech stack, commands, architecture
├── _rules/                 # Global rules (authoritative)
│   ├── _standard/          # Coding standards, security, architectural constraints
│   ├── _goal/              # High-level goals shared across milestones
│   ├── _contract/          # Data models, API contracts, schema definitions
│   └── _verification/      # Test commands, build requirements, definition of done
├── _template/              # Reusable templates
└── milestone-1/            # Active unit of work
    ├── _contract/          # Milestone-specific contracts
    ├── _goal/              # Milestone-specific goals
    ├── _plan/              # _todo.md + task-<n>.md specs
    └── _report/            # Reference material (investigations, task outputs)
```

Milestones may use numeric names (`milestone-1`) or ticket references (`milestone-PROJ-1234`).

## `.chief/_rules/` writing style

All markdown inside `_rules/` must be concise, structural, clear, and unambiguous. Include small code examples when useful. Ambiguity leads to incorrect autonomous decisions.

## `.chief/milestone-X/_plan/` conventions

- `_todo.md` — main checklist for the milestone
- `task-<n>.md` — detailed task spec (Objective, Scope, Rules & Contracts, Steps, Acceptance Criteria, Verification, Deliverables)
- Chief-agent marks completed tasks with `[x]`
- Task output files go in `.chief/milestone-X/_report/task-<n>/`

---

# Mandatory Plan Review

After writing or updating ANY plan, task spec, or decision document under `.chief/milestone-*/_plan/`, you MUST spawn the `review-plan` agent before proceeding to implementation or delegation.

During grill sessions: before presenting a recommendation, spawn `review-plan` to verify the recommendation against existing codebase behavior and prior decisions. Do this for EVERY recommendation, not just final plans.

Do NOT delegate to builder-agent until `review-plan` returns clean.

---

# Agent Architecture

## Chief-Agent (Planner / Orchestrator)

The decision-making brain. Reads the full rules hierarchy, creates and maintains `_plan/`, breaks work into small tasks (3–5 at a time), delegates to builder-agent and tester-agent, and decides next steps.

Defined in `.agents/agents/chief-agent.md`.

## Builder-Agent (Implementer)

The fast execution engine. Implements tasks from `.chief/<milestone>/_plan/task-<n>.md`, follows `.chief/_rules/_standard/**`, fixes type/lint/test fallout autonomously, runs local deterministic verification, and commits on success.

Builder-agent does NOT perform external acceptance testing, validate real environments, or make architecture decisions.

Defined in `.agents/agents/builder-agent.md`.

## Tester-Agent (Long-Running Verifier)

The integration and stability validator. Executes long-running or non-deterministic tests, validates UI flows, API integrations, auth flows, and environment-level behavior. Reports findings; does NOT implement code or patch bugs.

Defined in `.agents/agents/tester-agent.md`.

## Review-Plan-Agent (Quality Gate)

Reviews plans and decisions for internal consistency and alignment with prior discussion. Catches contradictions, hedging, overengineering, and scope leaks. Reports issues only; does not modify plans.

Defined in `.agents/agents/review-plan-agent.md`.

---

# Responsibility Separation

| Responsibility            | Builder | Tester     |
| ------------------------- | ------- | ---------- |
| Unit tests                | ✅       | ❌          |
| Type / lint / build       | ✅       | ❌          |
| Integration testing       | ❌       | ✅          |
| UI testing                | ❌       | ✅          |
| External auth validation  | ❌       | ✅          |
| Cloud / env checks        | ❌       | ✅          |
| Code fixes                | ✅       | ❌          |
| Architecture decisions    | ❌ (Chief)         | ❌ (Chief)  |
| Plan consistency review   | ❌ (Review-Plan)   | ❌ (Review-Plan)  |

---

# Core Design Philosophy

```
Human defines direction
  → Chief plans
  → Builder builds
  → Tester verifies
  → Chief decides
  → Repeat
```

Minimal human intervention. Maximum clarity and safety.

## Project configuration

Project-specific context (dev commands, tech stack, architecture, directory structure) is defined in `.chief/project.md`.
