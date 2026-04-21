# AGENTS.md

## Project Rules

<!-- WRITE YOUR PROJECT-SPECIFIC RULES HERE — highest authority -->
<!-- Examples: -->
<!-- - NEVER use ORM in this project -->
<!-- - All APIs MUST return JSON:API format -->
<!-- - MUST use pnpm, not npm -->

---

## Rules Hierarchy

1. **Project Rules** above (highest authority)
2. `.chief/_rules`
3. `.chief/milestone-X/_goal` (lowest authority)

If rules conflict, higher priority wins. Always.

---

## Chief Agent Framework

### Human Responsibilities

- Write and refine this file
- Maintain `.chief/_rules`
- Define milestone goals

### AI Responsibilities

- Follow this file strictly
- Follow `.chief/_rules`
- Follow milestone goals and contracts
- Ask for clarification only when multiple valid paths exist

### Directory Structure

```
.chief/
├── _rules/
│   ├── _standard/       # Coding standards, architecture constraints
│   ├── _contract/       # Data models, API contracts, schemas
│   ├── _goal/           # High-level goals (shared across milestones)
│   └── _verification/   # Test commands, build requirements, definition of done
├── _template/           # Scaffold for new milestones
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

### Execution Cycle

```
Human defines direction → Chief plans → Builder builds → Tester verifies → Chief decides → Repeat
```

### Rules for `.chief/_rules` Files

- MUST be concise, structural, clear
- MUST eliminate ambiguity
- Include small code examples when useful
- Anything unclear may lead to incorrect autonomous decisions

### Optional: Review-Plan-Agent

Reviews plans for internal consistency. Catches contradictions and scope leaks. Does not modify plans — reports issues only. Defined in `.agents/agents/review-plan-agent.md`.

---

## Project Configuration

Project-specific details (dev commands, tech stack, architecture) are defined in `.chief/project.md`.
