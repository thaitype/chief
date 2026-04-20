# AGENTS.md

## Overview

This project uses a structured **Chief Agent Framework** to enable goal-driven autonomous development with minimal human intervention.

The system is designed so that:

* Humans define **direction, rules, and constraints**
* The **chief-agent** plans and orchestrates work
* Builder and tester agents execute and verify tasks
* The system progresses milestone by milestone with clear contracts and verification

The primary objective is to reduce human involvement in execution while maintaining correctness, safety, and alignment with project goals.

---

# `.chief` Directory Structure

The `.chief` directory contains all structured planning, rules, goals, and execution state.

```
.chief
├── _rules
│   ├── _contract
│   ├── _goal
│   ├── _verification
│   └── _standard
├── _template
└── milestone-1
    ├── _contract
    ├── _goal
    ├── _plan
    └── _report
```

Multiple milestones may exist.

A milestone can be:

* a simple numeric milestone (milestone-1, milestone-2)
* or a real ticket reference (e.g. `milestone-PROJ-1234`)

---

# Rules Hierarchy Priority

Rules must always be resolved using the following priority:

1. **AGENTS.md** (highest authority)
2. `.chief/_rules`
3. `.chief/milestone-X/_goal` (lowest authority)

Example:
If AGENTS.md states:

> "Do not use MongoDB ObjectId in service layer"

But `.chief/_rules` states:

> "MongoDB ObjectId may be used in some cases"

Then **AGENTS.md always overrides**.

---

# Human vs AI Responsibilities

## Human Responsibilities

Humans focus primarily on:

* Writing and refining `AGENTS.md`
* Maintaining `_rules`
* Defining goals clearly

Humans should not micromanage implementation details.

Clear rules and goals allow agents to work autonomously and safely.

## AI Responsibilities

AI agents must:

* Follow AGENTS.md strictly
* Follow `.chief/_rules`
* Follow milestone goals and contracts
* Execute tasks safely and correctly
* Ask for clarification only when multiple valid paths exist

---

# `.chief/_rules` Directory

This directory defines global rules that apply to all milestones.

It contains four subfolders:

### `_standard`

General rules shared across all milestones:

* coding standards
* security policies
* database access rules
* architectural constraints

### `_goal`

General high-level goals shared across milestones.

### `_contract`

Shared system contracts:

* data models
* API contracts
* schema definitions
* system conventions

### `_verification`

Defines how work must be verified:

* test commands
* build requirements
* lint/type requirements
* definition of done

### Writing style rules for all rule files

All markdown inside `_rules` must be:

* concise
* structural
* clear
* not overly verbose
* include small code examples when useful
* eliminate ambiguity

Anything unclear may lead to incorrect autonomous decisions.

---

# `.chief/milestone-X` Directory

Each milestone has its own directory.

```
milestone-X
├── _contract
├── _goal
├── _plan
└── _report
```

## `_contract`

Milestone-specific contracts.
May be more detailed than global contracts, but must never conflict with them.

Examples:

* API schema for this milestone
* DB schema
* service boundaries

## `_goal`

Milestone-specific goals.
More detailed than global goals but must not conflict.

## `_plan`

Execution plan and task list for this milestone.

## `_report`

Reference material produced during the milestone. Examples: bug investigation reports, diagnostic reports, review results, performance analyses, task output folders. Not plans, contracts, or goals -- just reference documents.

---

# `.chief/milestone-X/_plan` Directory

Contains planning and execution tracking.

### Files

* `_todo.md` → main checklist for milestone
* `task-1.md`, `task-2.md`, etc → detailed task specs

### `_todo.md` Example

```md
# TODO List for Milestone X

- [ ] task-1: implement authentication module
- [ ] task-2: set up database schema
- [ ] task-3: write unit tests for user service
```

Chief-agent must update `_todo.md` by marking completed tasks:

```
[x]
```

Tasks should be kept small and clear.

## Task Output

Each task can have file output when needed, the output should be placed at `.chief/milestone-X/_report/task-Y/`

---

# Mandatory Plan Review

After writing or updating ANY plan, task spec, or decision document under `.chief/milestone-*/_plan/`, you MUST spawn the `review-plan` agent before proceeding to implementation or delegation.

During grill sessions: before presenting a recommendation, spawn review-plan agent to verify the recommendation against existing codebase behavior and prior decisions. Do this for EVERY recommendation, not just final plans.

Do NOT delegate to builder-agent until review-plan returns clean.

---

# 4-Agent Architecture

## 0. Review-Plan-Agent (Quality Gate)

Reviews plans and decisions for internal consistency and alignment with prior discussion. Catches contradictions, hedging, and scope leaks. Does not modify plans — reports issues only.

Triggered:
- After writing any task spec or plan file
- After grill-me sessions produce a plan
- Before delegating to builder-agent

Defined in `.agents/agents/review-plan-agent.md`.

## 1. Chief-Agent (Planner / Orchestrator)

The decision-making brain.

Responsibilities:

- Read `AGENTS.md`
- Read global rules under `.chief/_rules`
- Analyze milestone goals and contracts
- Create and maintain `_plan`
- Break work into small tasks (3–5 at a time)
- Delegate implementation to builder-agent
- Delegate long-running validation to tester-agent
- Update `_todo.md`
- Decide next steps

Chief-agent resolves ambiguity, ensures rule compliance, and minimizes unnecessary human intervention.

---

## 2. Builder-Agent (Implementer)

The fast execution engine.

Responsibilities:

- Implement tasks defined in `.chief/<milestone>/_plan/task-X.md`
- Follow `.chief/_rules/_standard`
- Fix type/lint/test fallout autonomously
- Run short deterministic verification commands
- Commit code after verification passes

Builder-agent handles:

- Unit tests
- Type checks
- Lint
- Local deterministic build verification

Builder-agent does NOT:

- Perform external acceptance testing
- Validate real environments
- Make architecture decisions
- Modify contracts unless explicitly allowed

---

## 3. Tester-Agent (Long-Running Verifier)

The integration and stability validator.

Responsibilities:

- Execute long-running or non-deterministic tests
- Validate UI flows
- Validate API integrations
- Validate authentication flows (e.g. Entra)
- Perform integration and end-to-end testing
- Validate environment-level behavior

Tester-agent does NOT:

- Implement code
- Patch bugs
- Refactor systems

Tester-agent reports findings back to chief-agent for decision.

---

# Responsibility Separation

| Responsibility Type      | Builder-Agent | Tester-Agent    |
| ------------------------ | ------------- | --------------- |
| Unit tests               | ✅             | ❌               |
| Type/lint/build checks   | ✅             | ❌               |
| Integration testing      | ❌             | ✅               |
| UI testing               | ❌             | ✅               |
| External auth validation | ❌             | ✅               |
| Cloud/environment checks | ❌             | ✅               |
| Code fixes               | ✅             | ❌               |
| Architecture decisions   | ❌             | ❌ (Chief)       |
| Plan consistency review  | ❌             | ❌ (Review-Plan) |

This separation prevents slow loops and keeps execution stable.

---

# Core Design Philosophy

This system is designed so that:

Human defines direction →
Chief-agent plans →
Builder builds →
Tester verifies →
Chief decides →
Repeat

Minimal human intervention.
Maximum clarity and safety.

## Project Configuration

Project-specific details (dev commands, tech stack, architecture, directory structure) are defined in `.chief/project.md`.
