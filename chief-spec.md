# Chief Agent Framework -- Design Spec

## Purpose

A structured framework for goal-driven autonomous development using AI agents. Humans define direction, rules, and constraints. Agents plan, execute, and verify work milestone by milestone.

The framework supports two modes:
- **Single-project** -- one project, one `.chief/` directory
- **Monorepo workspace** -- multiple projects, each with its own `.chief/`

---

## Mode Detection

The framework determines its mode by checking for `chief-workspace.yml` at the repo root.

| Condition | Mode |
|-----------|------|
| `chief-workspace.yml` exists | Monorepo workspace |
| `chief-workspace.yml` does not exist | Single-project |

This is the only detection mechanism. No flags, no env vars, no config.

---

## Single-Project Mode

### Directory Layout

```
repo-root/
├── CLAUDE.md                    (project rules -- highest authority)
├── .chief/
│   ├── _rules/
│   │   ├── _standard/           (coding standards, architectural constraints)
│   │   ├── _contract/           (data models, API contracts)
│   │   ├── _goal/               (high-level project goals)
│   │   └── _verification/       (test/build/lint requirements)
│   ├── _template/               (templates for requirements, analysis docs)
│   └── milestone-X/
│       ├── _goal/               (milestone objectives)
│       ├── _contract/           (milestone-specific contracts)
│       ├── _plan/               (todo list + task specs)
│       └── _report/             (reference material, task outputs)
└── src/                         (project source code)
```

### Rules Hierarchy (3 levels)

1. `CLAUDE.md` (highest)
2. `.chief/_rules/**`
3. `.chief/milestone-X/_goal/**` (lowest)

### Path Resolution

All `.chief/` paths are relative to repo root. No routing decision needed.

---

## Monorepo Workspace Mode

### Directory Layout

```
repo-root/
├── CLAUDE.md                    (workspace rules -- highest authority)
├── chief-workspace.yml          (project listing)
├── .chief/                      (workspace-level)
│   ├── _rules/                  (shared rules across all projects)
│   ├── _template/               (shared templates)
│   └── milestone-*/             (cross-project / infrastructure milestones)
├── project-a/
│   ├── CLAUDE.md                (project-specific rules)
│   └── .chief/
│       ├── _rules/              (project-specific rules)
│       ├── _template/           (project-specific templates)
│       └── milestone-*/         (project-specific milestones)
├── project-b/
│   ├── CLAUDE.md
│   └── .chief/
│       └── ...
└── shared/                      (shared infrastructure, IaC, etc.)
```

### `chief-workspace.yml`

```yml
projects:
  - project-a
  - project-b
```

Each listed project may have its own `CLAUDE.md` and `.chief/` directory.

### Rules Hierarchy (5 levels)

1. Workspace `CLAUDE.md` (repo root -- highest)
2. Workspace `.chief/_rules/**`
3. Project `CLAUDE.md` (e.g. `project-a/CLAUDE.md`)
4. Project `.chief/_rules/**` (e.g. `project-a/.chief/_rules/**`)
5. Milestone `_goal/**` (lowest)

### Milestone Routing

Milestones belong to a specific scope. The agent MUST resolve which `.chief/` to use:

1. If the user specifies a project → use `<project>/.chief/`
2. If the milestone is cross-project or infrastructure → use root `.chief/`
3. If ambiguous → **ask the user**
4. Never assume root `.chief/` is the default

### Rule Reading Order

**Project-scoped milestone** (e.g. `project-a/.chief/milestone-X`):
1. Workspace `CLAUDE.md`
2. Root `.chief/_rules/**`
3. Project `CLAUDE.md`
4. Project `.chief/_rules/**`
5. Milestone `_goal/**` and `_contract/**`

**Workspace-scoped milestone** (e.g. `.chief/milestone-X`):
1. Workspace `CLAUDE.md`
2. Root `.chief/_rules/**`
3. Milestone `_goal/**` and `_contract/**`

---

## `.chief/_rules` Directory

Four subdirectories, same structure at both workspace and project level:

| Subdirectory | Purpose | Examples |
|-------------|---------|----------|
| `_standard` | Coding standards, architectural constraints | design patterns, naming conventions, security policies |
| `_contract` | System contracts and data models | API schemas, DB schemas, service boundaries |
| `_goal` | High-level goals shared across milestones | project vision, quality targets |
| `_verification` | How work must be verified | test commands, lint/type requirements, definition of done |

### Rule File Style

All rule files must be:
- Concise and structural
- Clear with no ambiguity
- Include small code examples when useful
- Not overly verbose

Ambiguous rules lead to incorrect autonomous decisions.

---

## Milestone Structure

```
milestone-X/
├── _goal/          (what to achieve -- defined by human)
├── _contract/      (milestone-specific contracts)
├── _plan/          (execution plan)
│   ├── _todo.md    (task checklist)
│   └── task-N.md   (individual task specs)
└── _report/        (reference material, task outputs)
    └── task-N/     (output files for task N)
```

### Milestone Naming

- Simple numeric: `milestone-1`, `milestone-2`
- Ticket reference: `milestone-PROJ-1234`, `milestone-SM-13207`

### Milestone Creation Protocol

When creating a new milestone:

1. Resolve the correct `.chief/` scope (monorepo only)
2. Create directory structure: `_goal/`, `_contract/`, `_plan/`, `_report/`
3. **Do NOT write content into `_goal/`**
4. **Do NOT infer goals from branch names, ticket IDs, or any source**
5. Ask the human to provide the goal
6. Do not proceed to planning until `_goal/` has human-approved content

An empty `_goal/` is valid. A fabricated goal is not.

---

## `_plan` Directory

### `_todo.md`

Checklist of tasks. Max 3-5 tasks per planning batch.

```md
# TODO List for Milestone X

- [ ] task-1: implement authentication module
- [ ] task-2: set up database schema
- [x] task-3: write unit tests for user service
```

### `task-N.md`

Each task spec must include:

- **Objective** -- what will be achieved
- **Scope** -- included / excluded
- **Rules & Contracts** -- explicit file paths (from repo root in monorepo)
- **Steps** -- high-level, not code
- **Acceptance Criteria** -- measurable outcomes
- **Verification** -- commands/checks
- **Deliverables** -- expected files/outputs

Tasks should be small (15-90 minutes), independently verifiable.

---

## 3-Agent Architecture

### 1. Chief-Agent (Planner / Orchestrator)

The decision-making brain. Recommended model: most capable (e.g. Opus).

Responsibilities:
- Read and enforce rules hierarchy
- Analyze milestone goals
- Create and maintain `_plan`
- Break work into small tasks (3-5 at a time)
- Delegate to builder-agent and tester-agent
- Update `_todo.md`
- Decide next steps
- Reduce ambiguity proactively

Escalate to human when:
- Rule conflicts cannot be resolved
- Multiple valid approaches exist (present options)
- Verification repeatedly fails
- Requirements are ambiguous
- Milestone `_goal/` is empty or unclear

### 2. Builder-Agent (Implementer)

The fast execution engine. Recommended model: fast + capable (e.g. Sonnet).

Responsibilities:
- Implement tasks from `_plan/task-N.md`
- Follow rules hierarchy
- Fix type/lint/test fallout autonomously
- Run short verification commands
- Commit code after verification passes

Does NOT:
- Make architecture decisions
- Modify contracts unless explicitly allowed
- Perform integration/E2E testing

### 3. Tester-Agent (Long-Running Verifier)

The integration validator.

Responsibilities:
- Execute long-running or non-deterministic tests
- Validate UI flows, API integrations, auth flows
- Perform integration and E2E testing
- Report findings back to chief-agent

Does NOT:
- Implement code
- Patch bugs
- Refactor systems

### Responsibility Matrix

| Responsibility | Builder | Tester | Chief |
|----------------|---------|--------|-------|
| Unit tests | yes | -- | -- |
| Type/lint/build | yes | -- | -- |
| Integration tests | -- | yes | -- |
| UI testing | -- | yes | -- |
| Auth validation | -- | yes | -- |
| Cloud/env checks | -- | yes | -- |
| Code fixes | yes | -- | -- |
| Architecture decisions | -- | -- | yes |
| Rule interpretation | -- | -- | yes |

---

## CLAUDE.md Purpose

The highest authority file. Must not contain excessive detail.

### Single-project CLAUDE.md

Contains:
- Project overview
- Architecture and tech stack
- Development commands
- Directory structure
- Important rules

### Workspace CLAUDE.md (monorepo root)

Contains:
- Workspace overview and project listing
- Chief Agent Framework documentation
- Rules hierarchy (5-level)
- Shared references
- Workspace-level constraints

### Project CLAUDE.md (monorepo sub-project)

Contains:
- Project-specific overview
- Architecture and tech stack
- Development commands
- Directory structure
- Project-specific rules

Detailed rules always belong in `.chief/_rules`, not in CLAUDE.md.

---

## Templates

Optional templates stored in `.chief/_template/`:

- `requirement.md` -- functional/non-functional requirements, acceptance criteria
- `pre-dev-analysis.md` -- impact analysis, task breakdown, test cases

Templates exist at both workspace and project level. Project templates override workspace templates for the same filename.

---

## Git Strategy

Branch naming convention:
```
main.<milestone>              (milestone branch)
main.<milestone>.task-N       (task branch)
```

Merge strategy:
```bash
git checkout main.<milestone>
git merge --squash main.<milestone>.task-N
git commit -m "<milestone>: complete task-N"
```

---

## Invocation

### Chief-Agent

```
current milestone: milestone-X
current state: <what is being worked on>

start chief-agent

Let chief-agent review and plan work.
Escalate to human only when blocked by design decisions, scope limits, or ambiguities.
```

For monorepo, include project context:
```
project: admin-portal
current milestone: milestone-SM-13207
current state: <what is being worked on>

start chief-agent
```

### Builder-Agent

```
current state: <what is being worked on>

start builder-agent

Let builder-agent implement and fix issues autonomously.
Escalate to chief-agent only when blocked by design decisions, scope limits, or negative progress.
```

---

## Core Loop

```
Human defines direction
  → Chief-agent plans
    → Builder builds
      → Tester verifies
        → Chief decides
          → Repeat
```

Minimal human intervention. Maximum clarity and safety.
